class GeneratedProposal < ActiveRecord::Base
  belongs_to :user
  belongs_to :process_document
  has_many :generated_proposal_elements
end
