module PrioritiesHelper

  def has_process_documents?
    #TODO: Create optimized ActiveRecrods/SQL for this
    found = false
    @priority.priority_processes.each do |process|
      process.process_documents.each do |document|
        found = true
      end
    end
    found
  end

  def has_process_discussions?
    #TODO: Create optimized ActiveRecrods/SQL for this
    found = false
    @priority.priority_processes.each do |process|
      process.process_discussions.each do |discussion|
        found = true if discussion.process_speech_videos.get_first_published
      end
    end
    found
  end
end