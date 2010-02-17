class AddPortlets < ActiveRecord::Migration
  def self.up
    create_table "portlet_containers", :force => true do |t|
      t.string   "title"
      t.integer  "weight"
      t.integer  "user_id"
      t.boolean  "default_admin"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "portlet_positions", :force => true do |t|
      t.integer  "portlet_id"
      t.integer  "css_column"
      t.integer  "css_position"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "portlet_template_categories", :force => true do |t|
      t.string   "name"
      t.integer  "weight"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "portlet_templates", :force => true do |t|
      t.string   "name"
      t.string   "title"
      t.integer  "portlet_template_category_id"
      t.string   "locals_data_function"
      t.string   "partial_name"
      t.text     "description"
      t.integer  "weight"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "column_count",             :default => 1
    end
  
    create_table "portlets", :force => true do |t|
      t.integer  "portlet_template_id"
      t.integer  "portlet_container_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
  end
end
