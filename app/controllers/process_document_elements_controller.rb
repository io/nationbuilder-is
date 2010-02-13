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
 
class ProcessDocumentElementsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :index, :destroy, :new_change_proposal, 
                                           :create_change_proposal, :cancel_new_change_proposal]
  before_filter :admin_required, :only => [:edit, :update]

  before_filter :setup_user_hack

  # GET /process_document_elements
  # GET /process_document_elements.xml
  def index
    @process_document_elements = ProcessDocumentElement.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_document_elements }
    end
  end

  # GET /process_document_elements/1
  # GET /process_document_elements/1.xml
  def show
    @process_document_element = ProcessDocumentElement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @process_document_element }
    end
  end

  # GET /process_document_elements/new
  # GET /process_document_elements/new.xml
  def new
    @process_document_element = ProcessDocumentElement.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @process_document_element }
    end
  end

  # GET /process_document_elements/1/edit
  def edit
    @process_document_element = ProcessDocumentElement.find(params[:id])
  end

  # POST /process_document_elements
  # POST /process_document_elements.xml
  def create
    @process_document_element = ProcessDocumentElement.new(params[:process_document_element])

    respond_to do |format|
      if @process_document_element.save
        flash[:notice] = 'ProcessDocumentElement was successfully created.'
        format.html { redirect_to(@process_document_element) }
        format.xml  { render :xml => @process_document_element, :status => :created, :location => @process_document_element }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @process_document_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /process_document_elements/1
  # PUT /process_document_elements/1.xml
  def update
    @process_document_element = ProcessDocumentElement.find(params[:id])

    respond_to do |format|
      if @process_document_element.update_attributes(params[:process_document_element])
        flash[:notice] = 'ProcessDocumentElement was successfully updated.'
        format.html { redirect_to(@process_document_element) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @process_document_element.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /process_document_elements/1
  # DELETE /process_document_elements/1.xml
  def destroy
    @process_document_element = ProcessDocumentElement.find(params[:id])
    @process_document_element.destroy

    respond_to do |format|
      format.html { redirect_to(process_document_elements_url) }
      format.xml  { head :ok }
    end
  end
  
  def new_change_proposal
    @source_element = ProcessDocumentElement.find(params[:source_id])
    replace_div = "process_document_element_number_#{@source_element.sequence_number}"
    render :update do |page|
      page.replace_html replace_div, :partial => "process_document_elements/templates/#{@source_element.process_document.template_name}_new_change_proposal", :locals => {:document=> @source_element.process_document, :element => @source_element, :open_panel => true }
    end
  end
  
  def delete_change_proposal
    source_element = ProcessDocumentElement.find(params[:source_id])
    source_document = source_element.process_document
    sequence_number = source_element.sequence_number
    if (source_element.user and @user and source_element.user.id == @user.id) or (@user and @user.is_admin_subscribed)
      source_element.destroy
    end
    source_element = source_document.has_change_proposal_for_sequence_number?(sequence_number,true)
    replace_div = "process_document_element_number_#{source_element.sequence_number}"
    render :update do |page|  
      page.replace_html replace_div, :partial => "process_document_elements/templates/#{source_element.process_document.template_name}_element", :locals => {:document=> source_element.process_document, :element => source_element, :open_panel => true }
      page.visual_effect :highlight, replace_div,  {:restorecolor=>"#ffffff", :startcolor=>"#bbffbc", :endcolor=>"#ffffff"} 
    end    
  end

  def create_change_proposal
    source_element = ProcessDocumentElement.find(params[:source_id])
    change_proposal = source_element.clone
    change_proposal.user_id = session[:user_id]
    change_proposal.content = params[:source_element][:content]
    change_proposal.content_text_only = ""
    change_proposal.original_version=false
    change_proposal.created_at = Time.now
    change_proposal.updated_at = Time.now
    change_proposal.save
    replace_div = "process_document_element_number_#{change_proposal.sequence_number}"
    render :update do |page|  
      page.replace_html replace_div, :partial => "process_document_elements/templates/#{source_element.process_document.template_name}_element", :locals => {:document=> change_proposal.process_document, :element => change_proposal, :open_panel => true }
      page.visual_effect :highlight, replace_div,  {:restorecolor=>"#ffffff", :startcolor=>"#bbffbc", :endcolor=>"#ffffff"}
    end
  end

  def cancel_new_change_proposal
    source_element = ProcessDocumentElement.find(params[:source_id])
    replace_div = "process_document_element_number_#{source_element.sequence_number}"
    render :update do |page|  
      page.replace_html replace_div, :partial => "process_document_elements/templates/#{source_element.process_document.template_name}_element", :locals => {:document=> source_element.process_document, :element => source_element, :open_panel => true }
      page.visual_effect :highlight, replace_div,  {:restorecolor=>"#ffffff", :startcolor=>"#bbffbc", :endcolor=>"#ffffff"} 
    end
  end

  def view_element
    source_element = ProcessDocumentElement.find(params[:source_id])
    replace_div = "process_document_element_number_#{source_element.sequence_number}"
    render :update do |page|  
      page.replace_html replace_div, :partial => "process_document_elements/templates/#{source_element.process_document.template_name}_element", :locals => {:document=> source_element.process_document, :element => source_element, :open_panel => true }
      page.visual_effect :highlight, replace_div,  {:restorecolor=>"#ffffff", :startcolor=>"#bbffbc", :endcolor=>"#ffffff"}  
    end
  end
  
  def setup_user_hack
    if params[:user_id]
      @user = User.find(params[:user_id])
    elsif logged_in?
      @user = current_user
    end
  end
end
