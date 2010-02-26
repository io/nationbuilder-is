class CreateGeneratedProposals < ActiveRecord::Migration
  def self.up
    create_table :generated_proposals do |t|
      t.references :user, :process_document
      t.timestamps
    end
  end

  def self.down
    drop_table :generated_proposals
  end
end
