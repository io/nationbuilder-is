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
 
class ProcessSpeechVideo < ActiveRecord::Base
  acts_as_tree :order=>"from_time"
  
  belongs_to :process_speech_master_video
  belongs_to :process_discussion
  
  acts_as_rateable  

  def get_image_tag(padding_direction="top", image_size="tiny")
    speech_video_path = "/"+ENV['RAILS_ENV']+"/process_speech_videos/#{self.id}/"
    tiny_filename = "#{speech_video_path}#{image_size}_thumb_#{rand(5-2)+2}.png"
    ancenstor_number = self.ancestors.length
    "<a href=\"/process_speech_videos/show/#{self.id}\"><img src=\"#{tiny_filename}\" border=0 style=\"padding-#{padding_direction}:#{ancenstor_number*7}px\"></a>"
  end

  def get_video_link_tag
    speech_video_path = "/"+ENV['RAILS_ENV']+"/process_speech_videos/#{self.id}/"
    "#{speech_video_path}speech.flv"
  end
  
  def get_playlist_image_url(image_size="tiny")
    image_size+="_" unless image_size==""
    speech_video_path = "/"+ENV['RAILS_ENV']+"/process_speech_videos/#{self.id}/"
    "#{speech_video_path}#{image_size}thumb_#{rand(5-2)+2}.png"
  end

  def inpoint_s
    time_to_seconds(self.start_offset)
  end

  def duration_s
    time_to_seconds(self.duration)
  end

  def outpoint_s
    inpoint_s+duration_s
  end

  def modified_outpoint_s
    inpoint_s+self.modified_duration_s
  end

  def set_modified_duration_from_end_time(new_end_time)
    self.modified_duration_s = time_to_seconds(new_end_time)-inpoint_s
  end

  def modified_duration_long
    if self.modified_duration_s
      time = self.modified_duration_s
    else
      time = duration_s
    end
    seconds    =  time % 60
    time = (time - seconds) / 60
    minutes    =  time % 60
    time = (time - minutes) / 60
    hours      =  time % 24
    if hours > 0
      "#{hours} kl #{minutes} mín #{seconds} sek"
    elsif minutes > 0
      "#{minutes} mín #{seconds} sek"
    else
      "#{seconds} sek"
    end
  end
  
  def video_share_screenshot_image
    speech_video_path = "/"+ENV['RAILS_ENV']+"/process_speech_videos/#{self.id}/"
    "#{speech_video_path}small_thumb_#{rand(5-2)+2}.png"
  end

  def video_share_url
    "/"+ENV['RAILS_ENV']+"/process_speech_videos/#{self.id}/speech.flv"
  end
    
  def get_menu_title
    "#{self.process_discussion.meeting_date.strftime("%d/%m/%y")} #{self.process_discussion.from_time.strftime("%H:%M")}-#{self.process_discussion.to_time.strftime("%H:%M")}"
  end

  def video_share_swf_player_url(host)
    "http://#{host}/swf/flowplayer.swf?config={%22clip%22:{%22url%22:%22http://#{host}/production/process_speech_videos/#{self.id}/speech.flv%22,%22embedded%22:true}}"
  end

  def video_share_width
    "640"
  end

  def video_share_height
    "376"
  end

  def video_content_type
    "application/x-shockwave-flash"
  end

  def get_process
    self.process_discussion.priority_process
  end
  
  private

  def time_to_seconds(time)
    (time.strftime("%H").to_i*60*60) +
    (time.strftime("%M").to_i*60) +
    (time.strftime("%S").to_i)
  end
end
