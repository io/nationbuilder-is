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

class ProcessDocumentsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :index, :destroy]
  before_filter :admin_required, :only => [:edit, :update]

  # GET /process_documents
  # GET /process_documents.xml
  def index
    @process_documents = ProcessDocuments.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_documents }
    end
  end

  # GET /process_documents/1
  # GET /process_documents/1.xml
  def show
    @document = ProcessDocument.find(params[:id])
    @priority = @document.priority_process.priority
    unless fragment_exist?(@document)
      @document.reload(:include => [:process_document_elements])
      @page_title = t('processes.process_documents.title', :priority_name => @priority.name) 
    end
    respond_to do |format|
      format.html
      format.xml  { render :xml => @document }
    end
  end

  # GET /process_documents/new
  # GET /process_documents/new.xml
  def new
    @process_document = ProcessDocuments.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @process_document }
    end
  end

  # GET /process_documents/1/edit
  def edit
    @process_document = ProcessDocuments.find(params[:id])
  end

  # POST /process_documents
  # POST /process_documents.xml
  def create
    @process_document = ProcessDocuments.new(params[:process_document_element])

    respond_to do |format|
      if @process_document.save
        flash[:notice] = 'ProcessDocuments was successfully created.'
        format.html { redirect_to(@process_document) }
        format.xml  { render :xml => @process_document, :status => :created, :location => @process_document }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @process_document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /process_documents/1
  # PUT /process_documents/1.xml
  def update
    @process_document = ProcessDocuments.find(params[:id])

    respond_to do |format|
      if @process_document.update_attributes(params[:process_document_element])
        flash[:notice] = 'ProcessDocuments was successfully updated.'
        format.html { redirect_to(@process_document) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @process_document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /process_documents/1
  # DELETE /process_documents/1.xml
  def destroy
    @process_document = ProcessDocuments.find(params[:id])
    @process_document.destroy

    respond_to do |format|
      format.html { redirect_to(process_documents_url) }
      format.xml  { head :ok }
    end
  end
end
