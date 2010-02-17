namespace :fix do  

  desc "delete activities that don't have objects which are now nil"
  task :abandoned_activities => :environment do
    # not sure if this works yet
    activities = Activity.find_by_sql("SELECT * from activities where NOT EXISTS (select * from users where activities.other_user_id = users.id or activities.other_user_id is null)")
  end
  
  desc "fix default branches for users"
  task :default_branch => :environment do
    Government.all.last.update_user_default_branch
  end
  
  desc "fix endorsement counts"
  task :endorsement_counts => :environment do
    Government.current = Government.all.last    
    for p in Priority.find(:all)
      p.endorsements_count = p.endorsements.active_and_inactive.size
      p.up_endorsements_count = p.endorsements.endorsing.active_and_inactive.size
      p.down_endorsements_count = p.endorsements.opposing.active_and_inactive.size
      p.save_with_validation(false)      
    end
  end
  
  desc "fix endorsement positions"
  task :endorsement_positions => :environment do
    Government.current = Government.all.last    
    for u in User.active.at_least_one_endorsement.all(:order => "users.id asc")
      row = 0
      for e in u.endorsements.active.by_position
        row += 1
        e.update_attribute(:position,row) unless e.position == row
        u.update_attribute(:top_endorsement_id,e.id) if u.top_endorsement_id != e.id and row == 1
      end
      puts u.login
    end
  end
  
  desc "fix endorsement scores"
  task :endorsement_scores => :environment do
    Government.current = Government.all.last    
    Endorsement.active.find_in_batches(:include => :user) do |endorsement_group|
      for e in endorsement_group
        current_score = e.score
        new_score = e.calculate_score
        e.update_attribute(:score, new_score) if new_score != current_score
      end
    end      
  end
  
  desc "fix duplicate endorsements"
  task :duplicate_endorsements => :environment do
    Government.current = Government.all.last    
    # get users with duplicate endorsements
    endorsements = Endorsement.find_by_sql("
        select user_id, priority_id, count(*) as num_times
        from endorsements
        group by user_id,priority_id
  	    having count(*) > 1
    ")
    for e in endorsements
      user = e.user
      priority = e.priority
      multiple_endorsements = user.endorsements.active.find(:all, :conditions => ["priority_id = ?",priority.id], :order => "endorsements.position")
      if multiple_endorsements.length > 1
        for c in 1..multiple_endorsements.length-1
          multiple_endorsements[c].destroy
        end
      end
    end
  end  
  
  desc "fix duplicate top priority activities"
  task :duplicate_priority1_activities => :environment do
    Government.current = Government.all.last    
    models = [ActivityPriority1,ActivityPriority1Opposed]
    for model in models
      dupes = Activity.find_by_sql("select user_id, priority_id, count(*) as number from activities
      where type = '#{model}'
      group by user_id, priority_id
      order by count(*) desc")
      for a in dupes
        if a.number.to_i > 1
          activities = model.find(:all, :conditions => ["user_id = ? and priority_id = ?",a.user_id,a.priority_id], :order => "changed_at desc")
          for c in 1..activities.length-1
            activities[c].destroy
          end
        end
      end
    end
  end
  
  desc "fix discussion counts"
  task :discussion_counts => :environment do
    Government.current = Government.all.last    
    priorities = Priority.find(:all)
    for p in priorities
      p.update_attribute(:discussions_count,p.activities.discussions.for_all_users.active.size) if p.activities.discussions.for_all_users.active.size != p.discussions_count
    end
    points = Point.find(:all)
    for p in points
      p.update_attribute(:discussions_count,p.activities.discussions.for_all_users.active.size) if p.activities.discussions.for_all_users.active.size != p.discussions_count
    end
    docs = Document.find(:all)
    for d in docs
      d.update_attribute(:discussions_count, d.activities.discussions.for_all_users.active.size) if d.activities.discussions.for_all_users.active.size != d.discussions_count
    end
  end
  
  desc "fix tag counts"
  task :tag_counts => :environment do
    Government.current = Government.all.last    
    for t in Tag.all
      t.update_counts
      t.save_with_validation(false)
    end
  end  
  
  desc "fix branch counts"
  task :branch_counts => :environment do
    Government.current = Government.all.last    
    for b in Branch.all
      b.update_counts
      b.save_with_validation(false)
    end
    Branch.expire_cache
  end  

  desc "fix comment participant dupes"
  task :comment_participants => :environment do
    Government.current = Government.all.last    
    Activity.record_timestamps = false
    user_id = nil
    activity_id = nil
    for ac in ActivityCommentParticipant.active.find(:all, :order => "activity_id asc, user_id asc")
      if activity_id == ac.activity_id and user_id == ac.user_id
        ac.destroy
      else
        activity_id = ac.activity_id
        user_id = ac.user_id
        ac.update_attribute(:comments_count,ac.activity.comments.published.count(:conditions => ["user_id = ?",user_id]))
      end
    end
    Activity.record_timestamps = true
  end
  
  desc "fix helpful counts"
  task :helpful_counts => :environment do
    Government.current = Government.all.last 
    endorser_helpful_points = Point.find_by_sql("SELECT points.id, points.endorser_helpful_count, count(*) as number
    FROM points INNER JOIN endorsements ON points.priority_id = endorsements.priority_id
    	 INNER JOIN point_qualities ON point_qualities.user_id = endorsements.user_id AND point_qualities.point_id = points.id
    where endorsements.value  =1
    and point_qualities.value = true
    group by points.id, points.endorser_helpful_count
    having number <> endorser_helpful_count")
    for point in endorser_helpful_points
      point.update_attribute("endorser_helpful_count",point.number)
    end

    endorser_helpful_points = Document.find_by_sql("SELECT documents.id, documents.endorser_helpful_count, count(*) as number
    FROM documents INNER JOIN endorsements ON documents.priority_id = endorsements.priority_id
    	 INNER JOIN document_qualities ON document_qualities.user_id = endorsements.user_id AND document_qualities.document_id = documents.id
    where endorsements.value  =1
    and document_qualities.value = 1
    group by documents.id, documents.endorser_helpful_count
    having number <> endorser_helpful_count")
    for doc in endorser_helpful_points
      doc.update_attribute("endorser_helpful_count",doc.number)
    end    

    opposer_helpful_points = Point.find_by_sql("SELECT points.id, points.opposer_helpful_count, count(*) as number
    FROM points INNER JOIN endorsements ON points.priority_id = endorsements.priority_id
    	 INNER JOIN point_qualities ON point_qualities.user_id = endorsements.user_id AND point_qualities.point_id = points.id
    where endorsements.value = -1
    and point_qualities.value = true
    group by points.id, points.opposer_helpful_count
    having number <> opposer_helpful_count")
    for point in opposer_helpful_points
      point.update_attribute("opposer_helpful_count",point.number)
    end  

    opposer_helpful_points = Document.find_by_sql("SELECT documents.id, documents.opposer_helpful_count, count(*) as number
    FROM documents INNER JOIN endorsements ON documents.priority_id = endorsements.priority_id
    	 INNER JOIN document_qualities ON document_qualities.user_id = endorsements.user_id AND document_qualities.document_id = documents.id
    where endorsements.value = -1
    and document_qualities.value = 1
    group by documents.id, documents.opposer_helpful_count
    having number <> opposer_helpful_count")
    for doc in opposer_helpful_points
      doc.update_attribute("opposer_helpful_count",doc.number)
    end    

    endorser_unhelpful_points = Point.find_by_sql("SELECT points.id, points.endorser_unhelpful_count, count(*) as number
    FROM points INNER JOIN endorsements ON points.priority_id = endorsements.priority_id
    	 INNER JOIN point_qualities ON point_qualities.user_id = endorsements.user_id AND point_qualities.point_id = points.id
    where endorsements.value = 1
    and point_qualities.value = false
    group by points.id, points.endorser_unhelpful_count
    having number <> endorser_unhelpful_count")
    for point in endorser_unhelpful_points
      point.update_attribute("endorser_unhelpful_count",point.number)
    end  

    endorser_unhelpful_points = Document.find_by_sql("SELECT documents.id, documents.endorser_unhelpful_count, count(*) as number
    FROM documents INNER JOIN endorsements ON documents.priority_id = endorsements.priority_id
    	 INNER JOIN document_qualities ON document_qualities.user_id = endorsements.user_id AND document_qualities.document_id = documents.id
    where endorsements.value  =1
    and document_qualities.value = 0
    group by documents.id, documents.endorser_unhelpful_count
    having number <> endorser_unhelpful_count")
    for doc in endorser_unhelpful_points
      doc.update_attribute("endorser_unhelpful_count",doc.number)
    end    

    opposer_unhelpful_points = Point.find_by_sql("SELECT points.id, points.opposer_unhelpful_count, count(*) as number
    FROM points INNER JOIN endorsements ON points.priority_id = endorsements.priority_id
    	 INNER JOIN point_qualities ON point_qualities.user_id = endorsements.user_id AND point_qualities.point_id = points.id
    where endorsements.value = -1
    and point_qualities.value = false
    group by points.id, points.opposer_unhelpful_count
    having number <> opposer_unhelpful_count")
    for point in opposer_unhelpful_points
      point.update_attribute("opposer_unhelpful_count",point.number)
    end      

    opposer_unhelpful_points = Document.find_by_sql("SELECT documents.id, documents.opposer_unhelpful_count, count(*) as number
    FROM documents INNER JOIN endorsements ON documents.priority_id = endorsements.priority_id
    	 INNER JOIN document_qualities ON document_qualities.user_id = endorsements.user_id AND document_qualities.document_id = documents.id
    where endorsements.value = -1
    and document_qualities.value = 0
    group by documents.id, documents.opposer_unhelpful_count
    having number <> opposer_unhelpful_count")
    for doc in opposer_unhelpful_points
      doc.update_attribute("opposer_unhelpful_count",doc.number)
    end  

    #neutral counts
    Point.connection.execute("update points
    set neutral_unhelpful_count = unhelpful_count - endorser_unhelpful_count - opposer_unhelpful_count,
    neutral_helpful_count =  helpful_count - endorser_helpful_count - opposer_helpful_count")
    Document.connection.execute("update documents
    set neutral_unhelpful_count = unhelpful_count - endorser_unhelpful_count - opposer_unhelpful_count,
    neutral_helpful_count =  helpful_count - endorser_helpful_count - opposer_helpful_count")           
  end  
  
  desc "fix user counts"
  task :user_counts => :environment do
    Government.current = Government.all.last    
    users = User.find(:all)
    for u in users
      u.update_counts
      u.save_with_validation(false)
    end
  end
  
  desc "update obama_status on priorities"
  task :official_status => :environment do
    Government.current = Government.all.last    
    if Government.current.has_official?
      Priority.connection.execute("update priorities set obama_value = 1
      where obama_value <> 1 and id in (select priority_id from endorsements where user_id = #{govt.official_user_id} and value > 0 and status = 'active')")
      Priority.connection.execute("update priorities set obama_value = -1
      where obama_value <> -1 and id in (select priority_id from endorsements where user_id = #{govt.official_user_id} and value < 0 and status = 'active')")
      Priority.connection.execute("update priorities set obama_value = 0
      where obama_value <> 0 and id not in (select priority_id from endorsements where user_id = #{govt.official_user_id} and status = 'active')")
    end
  end  
  
  desc "re-process doc & talking point diffs"
  task :diffs => :environment do
    Government.current = Government.all.last    
    models = [Document,Point]
    for model in models
      for p in model.all
        revisions = p.revisions.by_recently_created
        puts p.name
        for row in 0..revisions.length-1
          if row == revisions.length-1
            revisions[row].content_diff = revisions[row].content
          else
            revisions[row].content_diff = HTMLDiff.diff(RedCloth.new(revisions[row+1].content).to_html,RedCloth.new(revisions[row].content).to_html)
          end
          revisions[row].save_with_validation(false)
        end
      end
    end
  end
  
  desc "run the auto_html processing on all objects.  used in case of changes to auto_html filtering rules"
  task :content_html => :environment do
    Government.current = Government.all.last    
    models = [Comment,Message,Point,Revision,Document,DocumentRevision]
    for model in models
      for p in model.all
        p.auto_html_prepare
        p.update_attribute(:content_html, p.content_html)
      end
    end
  end
  
  desc "this will fix the activity changed_ats"
  task :activities_changed_at => :environment do
    Government.current = Government.all.last    
    Activity.connection.execute("UPDATE activities set changed_at = created_at")
    for a in Activity.active.discussions.all
      if a.comments.published.size > 0
        a.update_attribute(:changed_at, a.comments.published.by_recently_created.first.created_at)
      end
    end
  end  
  
  desc "make all commenters on a discussion follow that discussion, this should only be done once"
  task :discussion_followers => :environment do
    Government.current = Government.all.last    
    for a in Activity.discussions.active.all
      for u in a.commenters
        a.followings.find_or_create_by_user_id(u.id)
      end
      a.followings.find_or_create_by_user_id(a.user_id) # add the owner of the activity too
    end
    Activity.connection.execute("DELETE FROM activities where type = 'ActivityDiscussionFollowingNew'")
  end
  
  desc "branch endorsements"
  task :branch_endorsements => :environment do
    Government.current = Government.all.last    
    for branch in Branch.all
      endorsement_scores = Endorsement.active.find(:all, 
        :select => "endorsements.priority_id, sum((#{Endorsement.max_position+1}-endorsements.position)*endorsements.value) as score, count(*) as endorsements_number", 
        :joins => "endorsements INNER JOIN priorities ON priorities.id = endorsements.priority_id", 
        :conditions => ["endorsements.user_id in (?) and endorsements.position <= #{Endorsement.max_position}",branch.user_ids], 
        :group => "endorsements.priority_id",       
        :order => "score desc")
      down_endorsement_counts = Endorsement.active.find(:all, 
        :select => "endorsements.priority_id, count(*) as endorsements_number", 
        :joins => "endorsements INNER JOIN priorities ON priorities.id = endorsements.priority_id", 
        :conditions => ["endorsements.value = -1 and endorsements.user_id in (?)",branch.user_ids], 
        :group => "endorsements.priority_id")    
      up_endorsement_counts = Endorsement.active.find(:all, 
        :select => "endorsements.priority_id, count(*) as endorsements_number", 
        :joins => "endorsements INNER JOIN priorities ON priorities.id = endorsements.priority_id", 
        :conditions => ["endorsements.value = 1 and endorsements.user_id in (?)",branch.user_ids], 
        :group => "endorsements.priority_id")      
      
      row = 0
      for e in endorsement_scores
        row += 1
        be = branch.endorsements.find_or_create_by_priority_id(e.priority_id.to_i)
        be.score = e.score.to_i
        be.endorsements_count = e.endorsements_number.to_i
        be.position = row
        down = down_endorsement_counts.detect {|d| d.priority_id == e.priority_id.to_i }
        if down
          be.down_endorsements_count = down.endorsements_number.to_i
        else
          be.down_endorsements_count = 0
        end
        up = up_endorsement_counts.detect {|d| d.priority_id == e.priority_id.to_i }
        if up
          be.up_endorsements_count = up.endorsements_number.to_i
        else
          be.up_endorsements_count = 0
        end            
        be.save_with_validation(false)
      end          
    end
  end
  
end