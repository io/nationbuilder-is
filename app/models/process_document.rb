# Copyright (C) 2008,2009,2010 Róbert Viðar Bjarnason
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class ProcessDocument < ActiveRecord::Base
  named_scope :by_latest, :order => "process_documents.created_at desc"  
  named_scope :item_limit, lambda{|limit| {:limit=>limit}}  

  belongs_to :user
  belongs_to :priority_process
  belongs_to :process_document_type

  has_many :process_document_elements
    
  def to_param
    "#{id}-#{self.priority_process.priority.name.parameterize_full}-#{external_type.parameterize_full}"
  end 

  def has_change_proposal_for_sequence_number?(sequence_number)
    ProcessDocumentElement.find(:first, :conditions => ["process_document_id = ? AND sequence_number = ? AND original_version = 0",self.id,sequence_number])
  end
  
  def get_all_change_proposals_for_sequence_number(sequence_number)
    proposals = []
    # First get the original
    proposals << ProcessDocumentElement.find(:first, :conditions => ["process_document_id = ? AND sequence_number = ? AND original_version = 1",self.id,sequence_number])
    change_proposals = ProcessDocumentElement.find(:all, :conditions => ["process_document_id = ? AND sequence_number = ? AND original_version = 0",self.id,sequence_number])
    for change_proposal in change_proposals
      proposals << change_proposal
    end
    proposals
  end
  
  def template_name
    self.process_document_type.template_name
  end
  
  def get_process_document_link
    #TODO: Remove this hack and use more Rails for this link generation
    "<a href=\"/process_documents/show/#{to_param}\">#{external_type}</a>"
  end
end
