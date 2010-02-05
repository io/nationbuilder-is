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

class SpeechVideoProcessing < VideoProcessing

  def self.process_speech(shell,logger,worker_config)
    @@logger = logger
    @@shell = shell
    @@worker_config = worker_config
    found = false
    ProcessSpeechMasterVideo.find(:all, :conditions=>"published = 1 AND in_processing = 0 AND url != ''", :order=>"url", :lock=>true).each do |master_video|
      master_video.in_processing = true
      master_video.save
      unless master_video.process_speech_videos.all_done? and not master_video.process_speech_videos.any_in_processing?
        found = true
        convert_all_speeches_to_flash(master_video)
        master_video.reload :lock=>true
        master_video.in_processing = false
        master_video.save
        break
      end
      master_video.reload :lock=>true
      master_video.in_processing = false
      master_video.save
    end
    check_load_and_wait
    if found
      return true
    else
      return false
    end
  end
  
  def self.convert_all_speeches_to_flash(master_video)
    master_video_filename = "#{RAILS_ROOT}/private/"+ENV['RAILS_ENV']+"/process_speech_master_videos/#{master_video.id}/master.flv"
    cut_points = []
    master_video.process_speech_videos.each do |video|
      speech_video_path = "#{RAILS_ROOT}/public/"+ENV['RAILS_ENV']+"/process_speech_videos/#{video.id}/"
      speech_video_first_tmp_filename = speech_video_path+"speech.tmp_1.flv"
      FileUtils.mkpath(speech_video_path)
      inpoint_ms = video.inpoint_s*1000

      inpoint_ms += 200 # mencoder video delay
      inpoint_ms -= 2000 # shift forward (after experimenting)                   
                  
      if video.modified_duration_s
        duration_ms = video.modified_duration_s*1000
      else
        duration_ms = video.duration_s*1000
      end
      outpoint_ms = inpoint_ms + duration_ms
      cut_points << [inpoint_ms,outpoint_ms,speech_video_first_tmp_filename]
    end

    @@shell.execute("flvtool2 -M -c -a -k -m #{cut_points.inspect.gsub(" ","").gsub("\"","\\\"")} #{master_video_filename}")

    master_video.process_speech_videos.each do |video|
      video.in_processing = true
      video.save
      @@logger.info("VIDEO TO PROCESS: #{video.title}")
      @@logger.info("PROCESS: #{video.process_discussion.meeting_url}")
      speech_video_path = "#{RAILS_ROOT}/public/"+ENV['RAILS_ENV']+"/process_speech_videos/#{video.id}/"
      speech_video_first_tmp_filename = speech_video_path+"speech.tmp_1.flv"
      speech_video_second_tmp_filename = speech_video_path+"speech.tmp_2.flv"
      speech_video_filename = speech_video_path+"speech.flv"
      @@shell.execute("mencoder -of lavf -ovc lavc -lavcopts vcodec=flv:vbitrate=400:keyint=230:vqmin=3 -oac copy -ofps 25 -vf \"harddup\"\
       #{speech_video_first_tmp_filename} -o #{speech_video_second_tmp_filename}")
      @@shell.execute("flvtool2 -U -c #{speech_video_second_tmp_filename}")
      @@shell.execute("rm #{speech_video_first_tmp_filename}")
      @@shell.execute("mv #{speech_video_second_tmp_filename} #{speech_video_filename}")
      begin
        timepoints = []
        slice_time_sec = video.duration_s/5
        slice_id = 1
        timepoints << [7,video.duration_s-1].min
        3.times do
          timepoints << slice_id*slice_time_sec
          slice_id+=1
        end
        timepoints << [video.duration_s-7,1].max
        pngid=0
        @@logger.info("Timepoints: #{timepoints.inspect} video duration: #{video.duration_s}")
        timepoints.sort.each do |time|
          filename = "thumb_#{pngid+=1}.png"
          if video.title.downcase.index("forseti")
            croptop = 30
            cropbottom = 190
          else
            croptop = 130
            cropbottom = 90
          end
          @@shell.execute("ffmpeg -i #{speech_video_filename} -an -croptop #{croptop} -cropbottom #{cropbottom} -cropright 150 -cropleft 238\
             -ss #{[time/3600, time/60 % 60, time % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')} -an -r 1 -vframes 1 -y #{speech_video_path}#{filename}")
          @@shell.execute("convert #{speech_video_path}#{filename} -resize 160x99 #{speech_video_path}small_#{filename}")
          @@shell.execute("convert #{speech_video_path}#{filename} -resize 80x50 #{speech_video_path}smaller_#{filename}")
          @@shell.execute("convert #{speech_video_path}#{filename} -resize 45x28 #{speech_video_path}tiny_#{filename}")
        end
      rescue
        @@logger.error("ERROR CREATING THUMBNAILS")
      end
      video.reload :lock=>true
      video.published = 1
      video.in_processing = 0
      video.save
    end
  end

  def self.print_all_sub_videos(video)
    if video.children.size > 0
      video.children.each do |subvideo| 
        print_video(subvideo)
        if subvideo.children.size > 0
          print_all_sub_videos(subvideo)
        end
      end
    end
  end

  def self.print_video(video)
    @@logger.info("level: #{video.ancestors.length} id:#{video.id} title:#{video.title}")
  end

  def self.print_tree
    csv = ProcessSpeechVideo.find(:all, :conditions=>"parent_id IS NULL")
    for video in csv
      print_video(video)
      print_all_sub_videos(video)
    end
  end
  
  def self.print_timecode
    ProcessSpeechVideo.find(:all, :conditions=>"published = 1", :order=>"start_offset").each do |video|
      if video.modified_duration_s
        @@logger.info("#{video.process_discussion.id} #{video.inpoint_s}-#{video.modified_outpoint_s} (#{video.modified_duration_s}s) - #{video.title}")
      else
        @@logger.info("#{video.process_discussion.id} #{video.inpoint_s}-#{video.outpoint_s} (#{video.duration_s}s) - #{video.title}")
      end
    end
  end  
end