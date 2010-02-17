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
 
class ProcessDocumentStatesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :index, :destroy]
  before_filter :admin_required, :only => [:edit, :update]

  # GET /process_document_states
  # GET /process_document_states.xml
  def index
    @process_document_states = ProcessDocumentState.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_document_states }
    end
  end

  # GET /process_document_states/1
  # GET /process_document_states/1.xml
  def show
    @process_document_state = ProcessDocumentState.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @process_document_state }
    end
  end

  # GET /process_document_states/new
  # GET /process_document_states/new.xml
  def new
    @process_document_state = ProcessDocumentState.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @process_document_state }
    end
  end

  # GET /process_document_states/1/edit
  def edit
    @process_document_state = ProcessDocumentState.find(params[:id])
  end

  # POST /process_document_states
  # POST /process_document_states.xml
  def create
    @process_document_state = ProcessDocumentState.new(params[:process_document_state])

    respond_to do |format|
      if @process_document_state.save
        flash[:notice] = 'ProcessDocumentState was successfully created.'
        format.html { redirect_to(@process_document_state) }
        format.xml  { render :xml => @process_document_state, :status => :created, :location => @process_document_state }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @process_document_state.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /process_document_states/1
  # PUT /process_document_states/1.xml
  def update
    @process_document_state = ProcessDocumentState.find(params[:id])

    respond_to do |format|
      if @process_document_state.update_attributes(params[:process_document_state])
        flash[:notice] = 'ProcessDocumentState was successfully updated.'
        format.html { redirect_to(@process_document_state) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @process_document_state.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /process_document_states/1
  # DELETE /process_document_states/1.xml
  def destroy
    @process_document_state = ProcessDocumentState.find(params[:id])
    @process_document_state.destroy

    respond_to do |format|
      format.html { redirect_to(process_document_states_url) }
      format.xml  { head :ok }
    end
  end
end
