class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :portlet_containers, :user_id
    add_index :portlet_positions, :portlet_id
    add_index :portlet_templates, :portlet_template_category_id
    
    add_index :portlets, :portlet_template_id
    add_index :portlets, :portlet_container_id

    add_index :priority_processes, :process_type_id

    add_index :process_discussions, :transcript_url
    add_index :process_discussions, :priority_process_id
    
    add_index :process_document_elements, :process_document_id    
    add_index :process_document_elements, :user_id

    add_index :process_documents, :process_document_state_id
    add_index :process_documents, :process_document_type_id
    add_index :process_documents, :priority_process_id
    
    add_index :process_speech_videos, :process_discussion_id
    add_index :process_speech_videos, :process_speech_master_video_id
  end

  def self.down
  end
end
