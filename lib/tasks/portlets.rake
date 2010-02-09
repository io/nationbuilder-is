namespace :portlets do
  desc "initialize"
  task(:initialize => :environment) do
    pc=PortletTemplateCategory.new
    pc.name="priorities.name"
    pc.weight = 1
    pc.save
    
    pc2=PortletTemplateCategory.new
    pc2.name="issues.name"
    pc2.weight = 2
    pc2.save
    
    pc3=PortletTemplateCategory.new
    pc3.name="network.name"
    pc3.weight = 3
    pc3.save
    
    pc4=PortletTemplateCategory.new
    pc4.name="news.name"
    pc4.weight = 4
    pc4.save
    
    pc5=PortletTemplateCategory.new
    pc5.name="processes.name"
    pc5.weight = 4
    pc5.save

    p=PortletTemplate.new
    p.name="priorities.newest.name"
    p.portlet_template_category_id=pc.id
    p.locals_data_function="setup_priorities_newest"
    p.partial_name = "priority_newest"
    p.item_limit = 3
    p.weight = 1
    p.save
    
    p=PortletTemplate.new
    p.name="priorities.top.name"
    p.portlet_template_category_id=pc.id
    p.locals_data_function="setup_priorities_top"
    p.partial_name = "priority_list"
    p.item_limit = 3
    p.weight = 2
    p.save
    
    p=PortletTemplate.new
    p.name="priorities.rising.name"
    p.portlet_template_category_id=pc.id
    p.locals_data_function="setup_priorities_rising"
    p.partial_name = "priority_list"
    p.item_limit = 3
    p.weight = 3
    p.save
    
    p=PortletTemplate.new
    p.name="priorities.falling.name"
    p.portlet_template_category_id=pc.id
    p.locals_data_function="setup_priorities_falling"
    p.partial_name = "priority_list"
    p.item_limit = 3
    p.weight = 4
    p.save
    
    p=PortletTemplate.new
    p.name="priorities.controversial.name"
    p.portlet_template_category_id=pc.id
    p.locals_data_function="setup_priorities_controversial"
    p.partial_name = "priority_list"
    p.item_limit = 3
    p.weight = 5
    p.save
    
    p=PortletTemplate.new
    p.name="priorities.finished.name"
    p.portlet_template_category_id=pc.id
    p.locals_data_function="setup_priorities_finished"
    p.partial_name = "priority_list"
    p.item_limit = 3
    p.weight = 6
    p.save
    
    p=PortletTemplate.new
    p.name="priorities.random.name"
    p.portlet_template_category_id=pc.id
    p.locals_data_function="setup_priorities_random"
    p.partial_name = "priority_list"
    p.item_limit = 5
    p.weight = 7
    p.caching_disabled = true
    p.save
    
    p=PortletTemplate.new
    p.name="issues.cloud.name"
    p.portlet_template_category_id=pc2.id
    p.locals_data_function=nil
    p.partial_name = "issues_cloud"
    p.item_limit = nil
    p.weight = 1
    p.save
    
    p=PortletTemplate.new
    p.name="issues.list.name"
    p.portlet_template_category_id=pc2.id
    p.locals_data_function=nil
    p.partial_name = "issues_list"
    p.item_limit = 3
    p.weight = 2
    p.save
    
    p=PortletTemplate.new
    p.name="network.influential.name"
    p.portlet_template_category_id=pc3.id
    p.locals_data_function=nil
    p.partial_name = "network_list"
    p.item_limit = 5
    p.weight = 1
    p.save
    
    p=PortletTemplate.new
    p.name="network.newest.name"
    p.portlet_template_category_id=pc3.id
    p.locals_data_function=nil
    p.partial_name = "network_newest"
    p.item_limit = 5
    p.weight = 2
    p.save
    
    p=PortletTemplate.new
    p.name="network.ambassadors.name"
    p.portlet_template_category_id=pc3.id
    p.locals_data_function=nil
    p.partial_name = "network_ambassadors"
    p.item_limit = 5
    p.weight = 3
    p.save
    
    p=PortletTemplate.new
    p.name="news.discussions.name"
    p.portlet_template_category_id=pc4.id
    p.locals_data_function=nil
    p.partial_name = "news_discussions"
    p.item_limit = 3
    p.weight = 1
    p.save
    
    p=PortletTemplate.new
    p.name="news.points.name"
    p.portlet_template_category_id=pc4.id
    p.locals_data_function=nil
    p.partial_name = "news_points"
    p.item_limit = 7
    p.weight = 2
    p.save
    
    p=PortletTemplate.new
    p.name="news.activities.name"
    p.portlet_template_category_id=pc4.id
    p.locals_data_function=nil
    p.partial_name = "news_activities"
    p.item_limit = 7
    p.weight = 3
    p.save
    
    p=PortletTemplate.new
    p.name="news.capital.name"
    p.portlet_template_category_id=pc4.id
    p.locals_data_function=nil
    p.partial_name = "news_capital"
    p.item_limit = 7
    p.weight = 4
    p.save
    
    p=PortletTemplate.new
    p.name="news.changes.name"
    p.portlet_template_category_id=pc4.id
    p.locals_data_function=nil
    p.partial_name = "news_changes"
    p.item_limit = 7
    p.weight = 5
    p.save    

    p=PortletTemplate.new
    p.name="processes.all_latest_video_discussions"
    p.portlet_template_category_id=pc5.id
    p.locals_data_function=nil
    p.partial_name = "process_latest_video_discussions"
    p.item_limit = 20
    p.weight = 1
    p.save    

    p=PortletTemplate.new
    p.name="processes.most_popular_videos"
    p.portlet_template_category_id=pc5.id
    p.locals_data_function=nil
    p.partial_name = "process_most_popular_videos"
    p.item_limit = 10
    p.weight = 2
    p.save    

    p=PortletTemplate.new
    p.name="processes.latest_processes"
    p.portlet_template_category_id=pc5.id
    p.locals_data_function = "setup_priorities_latest_processes"
    p.partial_name = "priority_list"
    p.item_limit = 3
    p.weight = 3
    p.save    

    p=PortletTemplate.new
    p.name="processes.latest_process_documents"
    p.portlet_template_category_id=pc5.id
    p.locals_data_function=nil
    p.partial_name = "process_latest_documents"
    p.item_limit = 5
    p.weight = 4
    p.save
  end

  desc "initialize2"
  task(:initialize2 => :environment) do    
  end
end
