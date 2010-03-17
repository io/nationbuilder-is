class ChangePointNameField < ActiveRecord::Migration
  def self.up
    change_column :points, :name, :string, :limit=>122
  end

  def self.down
  end
end
