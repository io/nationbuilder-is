class ModifyPortlet < ActiveRecord::Migration
  def self.up
    add_column :portlet_templates, :caching_disabled, :boolean, :default=>false
    remove_column :portlet_templates, :title
  end

  def self.down
  end
end
