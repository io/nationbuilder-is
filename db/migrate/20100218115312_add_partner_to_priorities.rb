class AddPartnerToPriorities < ActiveRecord::Migration
  def self.up
    add_column :priorities, :partner_id, :integer
  end

  def self.down
    remove_column :priorities, :partner_id
  end
end
