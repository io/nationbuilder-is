class AddPartnerToBlurbs < ActiveRecord::Migration
  def self.up
    add_column :blurbs, :partner_id, :integer
  end

  def self.down
    remove_column :blurbs, :partner_id
  end
end
