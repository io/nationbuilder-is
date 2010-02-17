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

class PriorityProcessesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :destroy]
  before_filter :admin_required, :only => [:edit, :update]

  # GET /processes
  # GET /processes.xml
  def index
      @processes = Process.find(:all, :order=>"external_id DESC")
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @processes }
    end
  end

  # GET /processes/1
  # GET /processes/1.xml
  # GET /processes/1.json
  def show
    @my_process = @priority_process = Process.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @priority_process }
      format.json  { render :xml => @priority_process }
    end
  end

  # GET /processes/new
  # GET /processes/new.xml
  def new
    @priority_process = Process.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @priority_process }
    end
  end

  # GET /processes/1/edit
  def edit
    @priority_process = Process.find(params[:id])
  end

  # POST /processes
  # POST /processes.xml
  def create
    @priority_process = Process.new(params[:process])

    respond_to do |format|
      if @priority_process.save
        flash[:notice] = 'Process was successfully created.'
        format.html { redirect_to(@process) }
        format.xml  { render :xml => @process, :status => :created, :location => @priority_process }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @priority_process.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /processes/1
  # PUT /processes/1.xml
  def update
    @priority_process = Process.find(params[:id])

    respond_to do |format|
      if @priority_process.update_attributes(params[:process])
        flash[:notice] = 'Process was successfully updated.'
        format.html { redirect_to(@process) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @priority_process.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /processes/1
  # DELETE /processes/1.xml
  def destroy
    @priority_process = Process.find(params[:id])
    @priority_process.destroy

    respond_to do |format|
      format.html { redirect_to(processes_url) }
      format.xml  { head :ok }
    end
  end

  def show_all_for_priority
    @priority = Priority.find(params[:id])    
    @priority_process = @priority.priority_process_root_node
    @page_title = t('processes.show_all.title', :priority_name => @priority.name) 
    respond_to do |format|
      format.html
      format.xml  { render :xml => @document }
    end
  end

end
