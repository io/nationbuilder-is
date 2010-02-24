class AddCustomDomainToPartners < ActiveRecord::Migration
  def self.up
    add_column :partners, :custom_domain, :string
  end

  def self.down
    remove_column :partners, :custom_domain
  end
end
