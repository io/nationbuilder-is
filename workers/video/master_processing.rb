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

class VideoProcessing
  @@shell = nil
  @@logger = nil  
  @@worker_config = nil

  def self.check_load_and_wait
    loop do
      break if load_avg[0] < @@worker_config["max_load_average"]
      info("Load Average #{load_avg[0]}, #{load_avg[1]}, #{load_avg[2]}")      
      info("Load average too high pausing for #{SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN}")
      sleep(SLEEP_WAITING_FOR_LOAD_TO_GO_DOWN)
    end
  end

  def self.ensure_mysql_connection
    unless ActiveRecord::Base.connection.active?
      unless ActiveRecord::Base.connection.reconnect!
        unless ActiveRecord::Base.connection.reconnect!
          @@logger.error("Couldn't reestablish connection to MYSQL")
        end
      end
    end
  end

  def self.load_avg
    results = ""
    IO.popen("cat /proc/loadavg") do |pipe|
      pipe.each("\r") do |line|
        results = line
        $defout.flush
      end
    end
    results.split[0..2].map{|e| e.to_f}
  end
end

class MasterProcessing < VideoProcessing

  def self.process_master(shell,logger,worker_config)
    @@logger=logger
    @@shell = shell
    @@worker_config = worker_config

    master_video = ProcessSpeechMasterVideo.find(:first, :conditions=>"published = 0 AND in_processing = 0 AND url != ''", :lock=>true, :order=>"url")
    if master_video
      master_video.in_processing = true
      master_video.save
      download_master_video(master_video)
      convert_master_to_flash(master_video)
      ensure_mysql_connection
      master_video.reload :lock=>true
      master_video.in_processing = false
      master_video.published = true
      master_video.save
    else
      @@logger.info("no more master videos to process")
    end
    check_load_and_wait
  end

  def self.download_master_video(master_video)
    master_video_path = "#{RAILS_ROOT}/private/"+ENV['RAILS_ENV']+"/process_speech_master_videos/#{master_video.id}/"
    master_video_filename = "#{master_video_path}master.wmv"
    url_to_mmsh = "mmsh"+master_video.url[4..master_video.url.length]
    FileUtils.mkpath(master_video_path)
    @@shell.execute("cvlc #{url_to_mmsh} --tcp-caching=120000 --http-caching=120000 --mms-caching=120000 --mms-timeout=120000 :demux=dump :demuxdump-file=#{master_video_filename} vlc://quit", "codec failed")
  end

  def self.convert_master_to_flash(master_video)
    master_video_filename = "#{RAILS_ROOT}/private/"+ENV['RAILS_ENV']+"/process_speech_master_videos/#{master_video.id}/master.wmv"
    master_video_flv_tmp_filename = "#{RAILS_ROOT}/private/"+ENV['RAILS_ENV']+"/process_speech_master_videos/#{master_video.id}/master.tmp.flv"
    master_video_flv_filename = "#{RAILS_ROOT}/private/"+ENV['RAILS_ENV']+"/process_speech_master_videos/#{master_video.id}/master.flv"
    @@shell.execute("mencoder -of lavf -ovc lavc -lavcopts vcodec=flv:vbitrate=1000:keyint=25:vqmin=3:acodec=libmp3lame:abitrate=160\
     -srate 44100 -af channels=1 -delay 0.20 -oac lavc -lavcopts acodec=libmp3lame:abitrate=160 -ofps 25 -vf \"harddup,crop=812:476:16:3,scale=640:375\"\
     #{master_video_filename} -o #{master_video_flv_tmp_filename}")
    @@shell.execute("mv #{master_video_flv_tmp_filename} #{master_video_flv_filename}")
    @@shell.execute("rm #{master_video_filename}")
  end  
end