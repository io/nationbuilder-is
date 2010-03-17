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

class DiscussionProcessing
  @@logger = nil

  def self.process_discussion_items(logger)
    @@logger = logger
    process_discussion = ProcessDiscussion.find(:first, :conditions=>["in_video_processing = 0 AND video_processing_complete = 0 AND to_time < ?",Time.now-2.hours], :order=>"meeting_date ASC", :lock=>true)
    if process_discussion
      process_discussion.in_video_processing = true
      process_discussion.save
      @@logger.info("Processing Process Discussion Id: #{process_discussion.id}")
      if process_discussion.listen_url.index("althingi.is")
        listen_url = process_discussion.listen_url
      else
        listen_url = "http://www.althingi.is#{process_discussion.listen_url}"
      end
      html_doc = Nokogiri::HTML(open(listen_url))
      @parent = nil
      last_current = nil
      last_link = nil
      last_indent = 0
      sequence_number = 0
      html_doc.xpath('//a').each do |link|
        if link.text=="Horfa"
          paragraph = link.parent
          if paragraph["style"]
            if paragraph["style"][0..11]=="text-indent:" or paragraph["style"][0..13]=="margin-top:5px"
              if paragraph["style"][0..13]=="margin-top:5px"
                last_current = @parent = ProcessSpeechVideo.new
                 @@logger.info("TOP LEVEL")
                last_indent = 0
              else
                indent = paragraph["style"][13..14].to_i
                 @@logger.info(indent)
                if indent>last_indent
                   @@logger.info("NEXT LEVEL")
                  @parent = last_current
                elsif indent<last_indent
                   @@logger.info("PREVIOUS LEVEL")
                  if @parent.parent
                    @parent = @parent.parent
                  else
                     @@logger.info("ERROR: Couldn't find parent keeping on same level")
                  end
                else
                   @@logger.info("SAME LEVEL")
                end
                last_current = @parent.children.new
                last_indent=indent            
              end
              last_current.process_discussion_id=process_discussion.id
              last_current.sequence_number = sequence_number+=1
              last_current.title = last_link.text.strip
              setup_video(last_current, link["href"])
               @@logger.info("LAST_TITLE: #{last_link.text}")
            end
          end
        end
        last_link = link
      end
      process_discussion.reload :lock=>true
      process_discussion.in_video_processing = false
      process_discussion.video_processing_complete = true
      process_discussion.save
      return true
    else
       @@logger.info("No more process discussions to process")
      return false
    end
  end
  
  def self.process_modify_durations(logger)
    @@logger = logger
    previous_video = nil
    process_discussion = ProcessDiscussion.find(:first, :conditions=>"in_video_processing = 0 AND has_modified_durations = 0 AND video_processing_complete = 1", :order=>"meeting_date ASC", :lock=>true)
    if process_discussion
      process_discussion.process_speech_videos.get_all_for_modified_duration.each do |video|
         @@logger.info("(#{video.inpoint_s}>#{previous_video.outpoint_s}) (#{video.inpoint_s-previous_video.outpoint_s})") if previous_video
        if previous_video and ((video.inpoint_s>previous_video.outpoint_s) and (video.inpoint_s-previous_video.outpoint_s<12) or video.inpoint_s<previous_video.outpoint_s)
           @@logger.info("modified duration for id #{previous_video.id} by next start offset")
          previous_video.set_modified_duration_from_end_time(video.start_offset)
          previous_video.save
        elsif previous_video and video.inpoint_s-previous_video.outpoint_s>=12
           @@logger.info("adding to durationfor id #{previous_video.id} for larger time skips")
          previous_video.modified_duration_s = previous_video.duration_s+6.seconds
          previous_video.save
        end
        if video==process_discussion.process_speech_videos.get_all_for_modified_duration.last and video.modified_duration_s == nil
           @@logger.info("adding to 2 seconds to last video id #{video.id} in discussion id #{process_discussion.id}")
          video.modified_duration_s = video.duration_s+2.seconds
        end
        video.has_checked_duration = true
        video.save
        previous_video = video
      end
      process_discussion.has_modified_durations = true
      process_discussion.save
      return true
    else
       @@logger.info("no more videos to modified duration to process")
      return false
    end
  end
  
  def self.setup_video(current, link)
    @@logger.info(LINK_PREFIX+link)
    link_sub_doc = Nokogiri::HTML(open(LINK_PREFIX+link))
    starttime = ""
    duration = ""
    main_video_url = ""
    title = ""
    link_sub_doc.xpath('//param').each do |param|
      if param["name"]=="FileName"
        @@logger.info("XMLLINK #{param["value"]}")
        link_xml_doc = Nokogiri::HTML(open(param["value"]))
        @@logger.info(link_xml_doc)
        link_xml_doc.xpath('//starttime').each do |s|
          starttime = s['value']
        end
        link_xml_doc.xpath('//duration').each do |s|
          duration = s['value']
        end
        link_xml_doc.xpath('//ref').each do |s|
          main_video_url = s['href']
        end
        link_xml_doc.xpath('//title').each do |s|
          title = s.text # Icelandic characters dont work here so this is not used
        end
        @@logger.info(main_video_url)
        master_video = ProcessSpeechMasterVideo.find_by_url(main_video_url)
        unless master_video
          master_video = ProcessSpeechMasterVideo.new
          master_video.url = main_video_url
          master_video.save
        end
        current.start_offset=Time.parse(starttime)
        current.duration=Time.parse(duration)
        current.process_speech_master_video_id = master_video.id
        old_video = ProcessSpeechVideo.find(:first, :conditions=>["start_offset = ? AND duration = ? and process_speech_master_video_id = ?",
                                                                       current.start_offset,current.duration,current.process_speech_master_video_id])
        unless old_video
          current.save
        else
          @@logger.info("FOUND OLD VIDEO: "+old_video.inspect)
        end
      end
    end
    @@logger.info("DID NOT FIND VIDEO!!!!!!!!!!!!!!") if duration==""
    @@logger.info(current.inspect)
  end
end