class ProcessParser

  @@stage_sequence_number = @@discussion_sequence_number = @@process_document_sequence_number = 0

  def self.get_stage_sequence_number(txt, process_type)
    if process_type == PROCESS_TYPE_LOG
      re1='(\\d+)'  # Integer Number 1
      re2='(\\.)' # Any Single Character 1
      re3='(\\s+)'  # White Space 1
      re4='(umræða)' # Word 1
      
      re=(re1+re2+re3+re4)
      m=Regexp.new(re,Regexp::IGNORECASE);
      if m.match(txt)
        int1=m.match(txt)[1];
      end
      
      return int1
    elsif process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
      if txt=="Fyrri umræða"
        return 1
      elsif txt=="Síðari umræða"
        return 2
      end
    end
  end
  
  def self.process_documents(next_sibling,current_process,process_document_type,process_type)
    tr_count = 3
    while next_sibling.at("tr[#{tr_count}]/td[1]")
      process_document = ProcessDocument.new
      process_document.sequence_number=@@process_document_sequence_number+=1
      process_document.priority_process_id = current_process.id
      process_document.stage_sequence_number = @@stage_sequence_number
      puts process_document.external_date = DateTime.strptime(next_sibling.at("tr[#{tr_count}]/td[1]").text.strip, "%d.%m.%Y")
      if next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]")
        puts process_document.external_id = next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]").text.strip
        puts process_document.external_link = "http://www.althingi.is"+next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]")['href']
      end
      if next_sibling.at("tr[#{tr_count}]/td[3]").text
        puts process_document.external_type = next_sibling.at("tr[#{tr_count}]/td[3]").text.strip
      else
        puts "ProcessDocument Type: unkown"
      end
      if next_sibling.at("tr[#{tr_count}]/td[4]").text
        puts process_document.external_author = next_sibling.at("tr[#{tr_count}]/td[4]").text.strip
      else
        puts "ProcessDocument Author: unkown"
      end
      
      if not ARGV.empty? and ARGV[0] == "force_refresh_on_document_parsing"
        oldpd = ProcessDocument.find_by_external_link(process_document.external_link)
        if oldpd
          oldpd.process_document_elements.each do |e|
            e.destroy
          end
          oldpd.destroy
        end
      end

      unless oldpd = ProcessDocument.find_by_external_link(process_document.external_link)
        puts "EXTERNAL_TYPE: #{process_document.external_type} STAT3: #{process_document.external_type[0..3]}"
        if process_document.external_type.index("frumvarp") or process_document.external_type.index("lög")
          document = LawProposalDocumentElement.create_elements(process_document, process_document.priority_process_id, process_document.id, process_document.external_link,process_type)
        elsif process_document.external_type.downcase.index("þingsályktun") or process_document.external_type.downcase.index("stjórnartillaga")
          document = LawProposalDocumentElement.create_elements(process_document, process_document.priority_process_id, process_document.id, process_document.external_link,process_type)
        else #TODO: Hack to get things saved
          document = LawProposalDocumentElement.create_elements(process_document, process_document.priority_process_id, process_document.id, process_document.external_link,process_type)
        end         
        if document
          unless old_process = PriorityProcess.find(:first, :conditions=>["priority_id = ? AND stage_sequence_number = ?",
                                                    current_process.priority_id, current_process.stage_sequence_number])
            current_process.save
          else
            current_process = old_process
          end
          puts "SAVING PROCESS DOCUMENT WITH PROCESS_ID = #{current_process.id}"
          process_document.priority_process_id = current_process.id
          process_document.process_document_type_id = process_document_type.id
          process_document.save
        end
        puts process_document.inspect
      else
        puts "Found old process document: " + oldpd.inspect
      end
      tr_count+=1
      puts ""
    end     
  end
  
  def self.process_discussion(next_sibling,current_process)
    tr_count = 3
    while next_sibling.at("tr[#{tr_count}]/td[1]")
      process_discussion = ProcessDiscussion.new
      process_discussion.sequence_number=@@discussion_sequence_number+=1
      process_discussion.priority_process_id = current_process.id
      process_discussion.stage_sequence_number = @@stage_sequence_number
      if next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0]
        puts "From time: "+date_from_time = next_sibling.at("tr[#{tr_count}]/td[1]").text.strip + " " + next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0].text.strip[0..4]
        puts "To time: "+ date_to_time = next_sibling.at("tr[#{tr_count}]/td[1]").text.strip + " " + next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0].text.strip[6..10]
        puts "SAME TIME" if date_from_time==date_to_time
        process_discussion.from_time = DateTime.strptime(date_from_time, "%d.%m.%Y %H:%M")
        process_discussion.to_time = DateTime.strptime(date_to_time, "%d.%m.%Y %H:%M")
        puts process_discussion.transcript_url="http://www.althingi.is"+next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0]['href']
      end
      if next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[1]
        puts process_discussion.listen_url=next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[1]['href']
      end
      puts process_discussion.meeting_date = DateTime.strptime(next_sibling.at("tr[#{tr_count}]/td[1]").text.strip, "%d.%m.%Y")
      if next_sibling.at("tr[#{tr_count}]/td[3]").text
        puts process_discussion.meeting_type = next_sibling.at("tr[#{tr_count}]/td[3]").text.strip
      else
        puts "Meeting Type: unkown"
      end
      if next_sibling.at("tr[#{tr_count}]/td[4]").text
        puts process_discussion.meeting_info = next_sibling.at("tr[#{tr_count}]/td[4]").text.strip        
        puts process_discussion.meeting_url = "http://www.althingi.is"+next_sibling.at("tr[#{tr_count}]/td[4]/a[@href]")['href'] if next_sibling.at("tr[#{tr_count}]/td[4]/a[@href]")
      else
        puts "Meeting Number: unkown"
      end
      unless date_from_time==date_to_time
        unless oldpd = ProcessDiscussion.find(:first, :conditions => ["transcript_url = ?", process_discussion.transcript_url])
          unless old_process = PriorityProcess.find(:first, :conditions=>["priority_id = ? AND stage_sequence_number = ?",
                                                                           current_process.priority_id, current_process.stage_sequence_number])
            current_process.save
          else
            current_process = old_process
          end
          process_discussion.priority_process_id = current_process.id
          process_discussion.save
          puts process_discussion.inspect
        else
          puts "Found old process discussion: " + oldpd.inspect
        end
      end
      tr_count+=1
    end
  end
  
  def self.get_process(url, presenter, external_id, external_name, process_type)
    html_doc = nil
    retries = 10
    begin
      Timeout::timeout(120){
        html_doc = Nokogiri::HTML(open(url))
      }
    rescue
      retries -= 1
      if retries > 0
        sleep 0.42 and retry
        puts "retry"
      else
        raise
      end
    end
    
    ur = URI.parse(url)
    ur_params = CGI.parse(ur.select(:query).to_s)
    ltg = ur_params["ltg"]
    mnr = ur_params["mnr"]
    
    if process_type == PROCESS_TYPE_LOG
      info_2 = "#{mnr}. mál lagafrumvarp"
    elsif process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
      info_2 = "#{mnr}. mál þingsályktunartillaga" 
    end
    info_3 = "#{ltg}. löggjafarþingi." 
    
    tags_to_collect = []
    
    if process_type == PROCESS_TYPE_LOG
      tags_to_collect << "lagafrumvörp"
      unless current_user = User.find_by_email("lagafrumvorp@skuggathing.is")
        current_user=User.new
        current_user.email = "lagafrumvorp@skuggathing.is"
        current_user.login = "Lagafrumvörp frá Alþingi"
        current_user.save(false)
      end
    elsif process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
      tags_to_collect << "þingsályktunartillögur"
      unless current_user = User.find_by_email("thingsalyktunartillaga@skuggathing.is")
        current_user=User.new
        current_user.email = "thingsalyktunartillaga@skuggathing.is"
        current_user.login = "Þingsályktunartillögur frá Alþingi"
        current_user.save(false)
      end
    end
    
    current_priority = Priority.new
    current_priority.external_info_1 = (html_doc/"h1.FyrirsognStorSv").text.strip
    current_priority.external_info_2 = info_2
    current_priority.external_info_3 = info_3
    current_priority.external_link = url
    current_priority.external_presenter = presenter
    current_priority.external_id = external_id
    current_priority.external_name = external_name
    current_priority.name = (html_doc/"h1.FyrirsognStorSv").text.strip
    current_priority.user = current_user
    current_priority.ip_address = "127.0.0.1"
    current_priority.issue_list = TagsParser.get_tags(html_doc,tags_to_collect)
    
    puts "***************************************** New Process *****************************************"
    puts "Process info 1: #{current_priority.external_info_1} 2: #{info_2} 3: #{info_3}"
    old_priority = Priority.find_by_external_link(url)
    if old_priority
      current_priority = old_priority
      puts "OLD PRIORITY "+old_priority.inspect
    else
      current_priority.save
      puts current_priority.inspect
    end
       
    unless process_type_record = ProcessType.find_by_process_type("Althingi Process")
      process_type_record = ProcessType.new
      process_type_record.process_type = "Althingi Process"
      process_type_record.template_name = "icelandic_parliament"
      process_type_record.save
    end
    
    unless process_document_type = ProcessDocumentType.find_by_process_document_type("Althingi Process")
      process_document_type = ProcessDocumentType.new
      process_document_type.process_document_type = "Althingi Process"
      process_document_type.template_name = "icelandic_parliament"
      process_document_type.save
    end
    
    @@stage_sequence_number = 0
    
    current_process = PriorityProcess.new
    current_process.process_type_id=process_type_record.id
    current_process.root_node = true
    current_process.parent_id = nil
    current_process.priority_id = current_priority.id
    current_process.process_type = ProcessType.find_by_process_type("Althingi Process")
    current_process.stage_sequence_number=@@stage_sequence_number+=1

    @@process_document_sequence_number = @@discussion_sequence_number = 0
    if (html_doc/"h2.FyrirsognMidSv").text==""
      next_sibling=html_doc.xpath('/html/body/table/tr[2]/td/table/tr/td[2]/div/table')
      puts "============"      
      puts next_sibling.at("tr[1]/td[1]").text
      puts "============"
      #@@stage_sequence_number = 0
      if next_sibling.at("tr[1]/td[1]").text=="Þingskjöl"
        process_documents(next_sibling,current_process,process_document_type,process_type)
      end
    else
     (html_doc/"h2.FyrirsognMidSv").each do |row|
        # Process stage_sequence
        puts row.text.strip
        #@@stage_sequence_number = get_stage_sequence_number(row.text.strip, process_type).to_i
        puts "Stage sequence number: #{@@stage_sequence_number}"
        puts "---------------------"      
        next_sibling = row.next_sibling
        @@process_document_sequence_number = @@discussion_sequence_number = 0
        while next_sibling and next_sibling.inspect[0..3]!="<div" and not next_sibling.inspect.include?("FyrirsognMidSv")
          if next_sibling.inspect[0..5]=="<table"
            puts "============"      
            puts next_sibling.at("tr[1]/td[1]").text
            puts "============"
            if next_sibling.at("tr[1]/td[1]").text=="Þingskjöl"
              process_documents(next_sibling,current_process,process_document_type,process_type)
            elsif (next_sibling.at("tr[1]/td[1]").inner_html)=="Umræða"
              process_discussion(next_sibling,current_process)
            end
            puts "++++++++++++"
          end
          next_sibling = next_sibling.next_sibling
        end
        puts "---------------------"
        old_process = current_process
        current_process = PriorityProcess.new
        current_process.process_type_id=process_type_record.id
        current_process.root_node = false
        current_process.parent_id = old_process.id
        current_process.priority_id = current_priority.id
        current_process.process_type = ProcessType.find_by_process_type("Althingi Process")
        current_process.stage_sequence_number=@@stage_sequence_number+=1
      end
    end
  end
end