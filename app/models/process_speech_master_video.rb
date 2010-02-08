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
 
class ProcessSpeechMasterVideo < ActiveRecord::Base
  has_many :process_speech_video
  
  has_many :process_speech_videos, 
                          :order => "process_speech_videos.start_offset ASC" do
    def get_one_to_process
      find :first, :conditions => "process_speech_videos.published = 0 AND process_speech_videos.in_processing = 0 AND process_speech_videos.has_checked_duration = 1", :lock => true
    end
    
    def all_done?
      a = count :all
      b = count :all, :conditions => "process_speech_videos.published = 1"
      a == b and b!=0
    end
    
    def any_in_processing?
      a = count :all, :conditions => "process_speech_videos.in_processing = 1"
      a != 0
    end
  end
  
  def self.get_latest_twenty(priority=nil)
    #TODO: Find a more optimized mysql way of doing this per priority filtering
    @latest_speech_discussions = []
    ProcessSpeechVideo.find(:all, :conditions=>"published = 1", :limit=>20, :select => 'DISTINCT(process_discussion_id)', 
                         :include=>"process_discussion", :order=>"updated_at DESC").each do |process_discussion_include|
      process_discussion = process_discussion_include.process_discussion
      @latest_speech_discussions << process_discussion unless priority and (process_discussion.priority_process.priority.id != priority.id)
    end
    @latest_speech_discussions
  end
end
