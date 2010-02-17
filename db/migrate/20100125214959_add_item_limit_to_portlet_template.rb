class AddItemLimitToPortletTemplate < ActiveRecord::Migration
  def self.up
    add_column :portlet_templates, :item_limit, :integer
  end

  def self.down
  end
end
