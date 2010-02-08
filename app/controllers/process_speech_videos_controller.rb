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
 
class ProcessSpeechVideosController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :index, :destroy]
  before_filter :admin_required, :only => [:edit, :update]
  
  def search
    if params[:priority_id]
      #TODO: Do the rejection with mysql
      @process_speech_videos = ProcessSpeechVideo.find(:all, :conditions=>['published = 1 AND LOWER(title) LIKE ?','%'+params[:search_query].downcase+'%'])
      @process_speech_videos = @process_speech_videos.reject {|x| x.process_discussion.priority_process.priority.id != params[:priority_id].to_i}
    else
      @process_speech_videos = ProcessSpeechVideo.find(:all, :conditions=>['published = 1 AND LOWER(title) LIKE ?','%'+params[:search_query].downcase+'%'])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_speech_videos }
    end
  end
  
  # GET /process_speech_videos
  # GET /process_speech_videos.xml
  def index
    @process_speech_videos = ProcessSpeechVideo.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_speech_videos }
    end
  end

  # GET /process_speech_videos/1
  # GET /process_speech_videos/1.xml
  def show
    if params[:only_update_details]
      a = params[:clip_info][0..params[:clip_info].index("speech.flv")-2]
      id_s = a[a.rindex("/")+1..a.length]
      @process_speech_video = ProcessSpeechVideo.find(id_s.to_i)
      @priority = @process_speech_video.process_discussion.priority_process.priority
      render :update do |page|  
        page.replace_html "process_speech_detail", :partial => "video_detail", :locals => {:process_speech_video=> @process_speech_video }  
        page.visual_effect :highlight, "process_speech_detail",  {:restorecolor=>"#ffffff", :startcolor=>"#cccccc", :endcolor=>"#ffffff"}  
      end
    else
      @process_speech_video = ProcessSpeechVideo.find(params[:id])
      @priority = @process_speech_video.process_discussion.priority_process.priority
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @process_speech_video }
      end
    end
  end

  # GET /process_speech_videos/new
  # GET /process_speech_videos/new.xml
  def new
    @process_speech_video = ProcessSpeechVideo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @process_speech_video }
    end
  end

  # GET /process_speech_videos/1/edit
  def edit
    @process_speech_video = ProcessSpeechVideo.find(params[:id])
  end

  # POST /process_speech_videos
  # POST /process_speech_videos.xml
  def create
    @process_speech_video = ProcessSpeechVideo.new(params[:process_speech_video])

    respond_to do |format|
      if @process_speech_video.save
        flash[:notice] = 'ProcessSpeechVideo was successfully created.'
        format.html { redirect_to(@process_speech_video) }
        format.xml  { render :xml => @process_speech_video, :status => :created, :location => @process_speech_video }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @process_speech_video.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /process_speech_videos/1
  # PUT /process_speech_videos/1.xml
  def update
    @process_speech_video = ProcessSpeechVideo.find(params[:id])

    respond_to do |format|
      if @process_speech_video.update_attributes(params[:process_speech_video])
        flash[:notice] = 'ProcessSpeechVideo was successfully updated.'
        format.html { redirect_to(@process_speech_video) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @process_speech_video.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /process_speech_videos/1
  # DELETE /process_speech_videos/1.xml
  def destroy
    @process_speech_video = ProcessSpeechVideo.find(params[:id])
    @process_speech_video.destroy

    respond_to do |format|
      format.html { redirect_to(process_speech_videos_url) }
      format.xml  { head :ok }
    end
  end
end
