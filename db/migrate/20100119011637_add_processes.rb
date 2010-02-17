class AddProcesses < ActiveRecord::Migration
  def self.up
    create_table "process_discussions", :force => true do |t|
      t.datetime "meeting_date"
      t.string   "external_id"
      t.string   "external_link"
      t.integer  "stage_sequence_number"
      t.integer  "sequence_number"
      t.datetime "to_time"
      t.datetime "from_time"
      t.string   "transcript_url"
      t.string   "listen_url"
      t.string   "meeting_info"
      t.string   "meeting_type"
      t.string   "meeting_url"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "priority_process_id"
      t.boolean  "processed_for_speech_videos"
      t.boolean  "published"
      t.boolean  "in_video_processing",         :default => false
      t.boolean  "video_processing_complete",   :default => false
      t.boolean  "has_modified_durations",      :default => false
    end
  
    create_table "process_document_elements", :force => true do |t|
      t.integer  "sequence_number"
      t.integer  "process_document_id"
      t.integer  "parent_id"
      t.binary   "content",           :limit => 2147483647
      t.binary   "content_text_only", :limit => 2147483647
      t.string   "content_number"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
      t.integer  "content_type"
      t.boolean  "original_version"
    end
  
    create_table "process_document_states", :force => true do |t|
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "process_document_types", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "template_name"
      t.string   "process_document_type"
    end
  
    create_table "process_documents", :force => true do |t|
      t.integer  "process_document_state_id"
      t.integer  "process_document_type_id"
      t.datetime "voting_close_time"
      t.boolean  "published"
      t.string   "external_name"
      t.string   "external_author"
      t.string   "external_state"
      t.datetime "external_creation_date"
      t.string   "external_link"
      t.datetime "external_date"
      t.string   "external_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "process_document_frozen"
      t.integer  "user_id"
      t.integer  "priority_process_id"
      t.integer  "process_document_id"
      t.boolean  "original_version"
      t.integer  "stage_sequence_number"
      t.integer  "sequence_number"
      t.string   "external_type"
    end
  
    create_table "process_speech_master_videos", :force => true do |t|
      t.string   "url"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "in_processing", :default => false
      t.boolean  "published",     :default => false
    end
  
    add_index "process_speech_master_videos", ["url"], :name => "index_process_speech_master_videos_on_url", :unique => true
  
    create_table "process_speech_videos", :force => true do |t|
      t.integer  "process_discussion_id"
      t.string   "title"
      t.datetime "to_time"
      t.datetime "from_time"
      t.integer  "sequence_number"
      t.integer  "parent_id"
      t.integer  "process_speech_master_video_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.time     "start_offset"
      t.time     "duration"
      t.boolean  "in_processing",               :default => false
      t.boolean  "published",                   :default => false
      t.integer  "modified_duration_s"
      t.boolean  "has_checked_duration",        :default => false
    end
  
    create_table "process_types", :force => true do |t|
      t.string   "process_type"
      t.string   "template_name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    create_table "priority_processes", :force => true do |t|
      t.integer  "external_id"
      t.string   "external_link"
      t.string   "external_name"
      t.integer  "process_type_id"
      t.integer  "sequence_number"
      t.integer  "stage_sequence_number"
      t.boolean  "root_node"
      t.integer  "parent_id"
      t.integer  "priority_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "archived",      :default => false
    end
    
    create_table "ratings", :force => true do |t|
      t.integer  "rating",                      :default => 0
      t.datetime "created_at",                                  :null => false
      t.integer  "rateable_id",                 :default => 0,  :null => false
      t.integer  "user_id",                     :default => 0,  :null => false
      t.string   "rateable_type", :limit => 50, :default => "", :null => false
    end
  
    add_index "ratings", ["user_id"], :name => "fk_ratings_user"

    add_column :priorities, :external_info_1, :string
    add_column :priorities, :external_info_2, :string
    add_column :priorities, :external_info_3, :string
    add_column :priorities, :external_link, :string
    add_column :priorities, :external_presenter, :string
    add_column :priorities, :external_id, :string
    add_column :priorities, :external_name, :string
  end

  def self.down
  end
end
