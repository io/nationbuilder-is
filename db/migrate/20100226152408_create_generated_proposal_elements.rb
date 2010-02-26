class CreateGeneratedProposalElements < ActiveRecord::Migration
  def self.up
    create_table :generated_proposal_elements do |t|
      t.references :generated_proposal, :process_document_element
      t.timestamps
    end
  end

  def self.down
    drop_table :generated_proposal_elements
  end
end
