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

class ProcessDiscussionsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :index, :destroy]
  before_filter :admin_required, :only => [:edit, :update]

  # GET /process_discussionss
  # GET /process_discussionss.xml
  def index
    @process_discussions = ProcessDiscussion.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_discussions }
    end
  end

  # GET /process_discussionss/1
  # GET /process_discussionss/1.xml
  def show
    @process_discussions = ProcessDiscussion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @process_discussions }
    end
  end

  # GET /process_discussionss/new
  # GET /process_discussionss/new.xml
  def new
    @process_discussions = ProcessDiscussion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @process_discussions }
    end
  end

  # GET /process_discussionss/1/edit
  def edit
    @process_discussions = ProcessDiscussion.find(params[:id])
  end

  # POST /process_discussionss
  # POST /process_discussionss.xml
  def create
    @process_discussions = ProcessDiscussion.new(params[:process_discussions])

    respond_to do |format|
      if @process_discussions.save
        flash[:notice] = 'ProcessDiscussion was successfully created.'
        format.html { redirect_to(@process_discussions) }
        format.xml  { render :xml => @process_discussions, :status => :created, :location => @process_discussions }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @process_discussions.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /process_discussionss/1
  # PUT /process_discussionss/1.xml
  def update
    @process_discussions = ProcessDiscussion.find(params[:id])

    respond_to do |format|
      if @process_discussions.update_attributes(params[:process_discussions])
        flash[:notice] = 'ProcessDiscussion was successfully updated.'
        format.html { redirect_to(@process_discussions) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @process_discussions.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /process_discussionss/1
  # DELETE /process_discussionss/1.xml
  def destroy
    @process_discussions = ProcessDiscussion.find(params[:id])
    @process_discussions.destroy

    respond_to do |format|
      format.html { redirect_to(process_discussionss_url) }
      format.xml  { head :ok }
    end
  end
end
