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

class ProcessSpeechMasterVideosController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :index, :destroy]
  before_filter :admin_required, :only => [:edit, :update]

  # GET /process_speech_master_videos
  # GET /process_speech_master_videos.xml
  def index
    @process_speech_master_videos = ProcessSpeechMasterVideo.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_speech_master_videos }
    end
  end

  # GET /process_speech_master_videos/1
  # GET /process_speech_master_videos/1.xml
  def show
    @process_speech_master_video = ProcessSpeechMasterVideo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @process_speech_master_video }
    end
  end

  # GET /process_speech_master_videos/new
  # GET /process_speech_master_videos/new.xml
  def new
    @process_speech_master_video = ProcessSpeechMasterVideo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @process_speech_master_video }
    end
  end

  # GET /process_speech_master_videos/1/edit
  def edit
    @process_speech_master_video = ProcessSpeechMasterVideo.find(params[:id])
  end

  # POST /process_speech_master_videos
  # POST /process_speech_master_videos.xml
  def create
    @process_speech_master_video = ProcessSpeechMasterVideo.new(params[:process_speech_master_video])

    respond_to do |format|
      if @process_speech_master_video.save
        flash[:notice] = 'ProcessSpeechMasterVideo was successfully created.'
        format.html { redirect_to(@process_speech_master_video) }
        format.xml  { render :xml => @process_speech_master_video, :status => :created, :location => @process_speech_master_video }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @process_speech_master_video.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /process_speech_master_videos/1
  # PUT /process_speech_master_videos/1.xml
  def update
    @process_speech_master_video = ProcessSpeechMasterVideo.find(params[:id])

    respond_to do |format|
      if @process_speech_master_video.update_attributes(params[:process_speech_master_video])
        flash[:notice] = 'ProcessSpeechMasterVideo was successfully updated.'
        format.html { redirect_to(@process_speech_master_video) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @process_speech_master_video.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /process_speech_master_videos/1
  # DELETE /process_speech_master_videos/1.xml
  def destroy
    @process_speech_master_video = ProcessSpeechMasterVideo.find(params[:id])
    @process_speech_master_video.destroy

    respond_to do |format|
      format.html { redirect_to(process_speech_master_videos_url) }
      format.xml  { head :ok }
    end
  end
end
