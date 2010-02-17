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
 
class ProcessDocumentTypesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :index, :destroy]
  before_filter :admin_required, :only => [:edit, :update]

  # GET /process_document_types
  # GET /process_document_types.xml
  def index
    @process_document_types = ProcessDocumentType.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_document_types }
    end
  end

  # GET /process_document_types/1
  # GET /process_document_types/1.xml
  def show
    @process_document_type = ProcessDocumentType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @process_document_type }
    end
  end

  # GET /process_document_types/new
  # GET /process_document_types/new.xml
  def new
    @process_document_type = ProcessDocumentType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @process_document_type }
    end
  end

  # GET /process_document_types/1/edit
  def edit
    @process_document_type = ProcessDocumentType.find(params[:id])
  end

  # POST /process_document_types
  # POST /process_document_types.xml
  def create
    @process_document_type = ProcessDocumentType.new(params[:process_document_type])

    respond_to do |format|
      if @process_document_type.save
        flash[:notice] = 'ProcessDocumentType was successfully created.'
        format.html { redirect_to(@process_document_type) }
        format.xml  { render :xml => @process_document_type, :status => :created, :location => @process_document_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @process_document_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /process_document_types/1
  # PUT /process_document_types/1.xml
  def update
    @process_document_type = ProcessDocumentType.find(params[:id])

    respond_to do |format|
      if @process_document_type.update_attributes(params[:process_document_type])
        flash[:notice] = 'ProcessDocumentType was successfully updated.'
        format.html { redirect_to(@process_document_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @process_document_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /process_document_types/1
  # DELETE /process_document_types/1.xml
  def destroy
    @process_document_type = ProcessDocumentType.find(params[:id])
    @process_document_type.destroy

    respond_to do |format|
      format.html { redirect_to(process_document_types_url) }
      format.xml  { head :ok }
    end
  end
end
