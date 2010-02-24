class AddPartnerToEmailTemplates < ActiveRecord::Migration
  def self.up
    add_column :email_templates, :partner_id, :integer
    
    # Set all curent email templates partner id to 0 # FIXME: This is a hack as we never have partner with id 0
    EmailTemplate.all.each do |et|
      et.update_attribute :partner_id, 0
    end
  end

  def self.down
    remove_column :email_templates, :partner_id
  end
end
