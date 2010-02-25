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

class ProcessDocumentElement < ActiveRecord::Base
  belongs_to :user
  belongs_to :process_document
  has_many :sentences
  
  after_save :touch_document
  before_destroy :touch_document

  named_scope :articles, :conditions => "content_type = 3"

  acts_as_rateable
  
  def touch_document
    self.process_document.touch
  end

  def children
    ProcessDocumentElement.all(:conditions => "parent_id = #{id}")
  end

  def user_proposals
    ProcessDocumentElement.all(:conditions => "parent_id = #{id} and not user_id is null")
  end

end
