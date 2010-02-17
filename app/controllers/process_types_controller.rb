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

class ProcessTypesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :index, :destroy]
  before_filter :admin_required, :only => [:edit, :update]

  # GET /process_types
  # GET /process_types.xml
  def index
    @process_types = ProcessType.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_types }
    end
  end

  # GET /process_types/1
  # GET /process_types/1.xml
  def show
    @process_type = ProcessType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @process_type }
    end
  end

  # GET /process_types/new
  # GET /process_types/new.xml
  def new
    @process_type = ProcessType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @process_type }
    end
  end

  # GET /process_types/1/edit
  def edit
    @process_type = ProcessType.find(params[:id])
  end

  # POST /process_types
  # POST /process_types.xml
  def create
    @process_type = ProcessType.new(params[:process_type])

    respond_to do |format|
      if @process_type.save
        flash[:notice] = 'ProcessType was successfully created.'
        format.html { redirect_to(@process_type) }
        format.xml  { render :xml => @process_type, :status => :created, :location => @process_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @process_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /process_types/1
  # PUT /process_types/1.xml
  def update
    @process_type = ProcessType.find(params[:id])

    respond_to do |format|
      if @process_type.update_attributes(params[:process_type])
        flash[:notice] = 'ProcessType was successfully updated.'
        format.html { redirect_to(@process_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @process_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /process_types/1
  # DELETE /process_types/1.xml
  def destroy
    @process_type = ProcessType.find(params[:id])
    @process_type.destroy

    respond_to do |format|
      format.html { redirect_to(process_types_url) }
      format.xml  { head :ok }
    end
  end
end
