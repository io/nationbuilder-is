require "combiner"

class UidiffController < ApplicationController

  def index
    redirect_to :action => :new
  end

  def new
    @proposal = ProcessDocument.find(142)
  end

  def edit
    @generated_proposal = GeneratedProposal.find(params[:id])
    @proposal = @generated_proposal.process_document
  end

  def save
    @proposal = ProcessDocument.find(params[:process_document][:id])
    # @proposal_elements = []
    # @change_elements = []

    gp = GeneratedProposal.new({
      :user => current_user,
      :process_document => @proposal
    })

    # Get the list of document elements from the proposal
    @proposal.process_document_elements.articles.each do |element|
      change_elements = params[:change_elements].blank? ? [] : ProcessDocumentElement.all(:conditions => "parent_id = #{element.id} and id in (#{params[:change_elements]})")
      gp.generated_proposal_elements.build({
        :process_document_element => change_elements.empty? ? element.children.first : change_elements.first
      })
    end

    gp.save

    # # Get the list of document elements from the proposal
    # @proposal.process_document_elements.articles.each do |element|
    #   @change_elements = params[:change_elements].blank? ? [] : ProcessDocumentElement.all(:conditions => "parent_id = #{element.id} and id in (#{params[:change_elements]})")
    #   @proposal_elements[element.content_number.to_i] = @change_elements.empty? ? element.children.first.content : @change_elements.first.content
    # end

    redirect_to :action => :preview, :id => gp
  end

  def preview
    @proposal = GeneratedProposal.find(params[:id])
  end

  def preview_original
    # Get all objects
    @priority = Priority.find(45)
    @law = ProcessDocument.find(264)
    @proposal = ProcessDocument.find(142)

    combiner = Combiner.new

    @law_elements = combiner.put_law_document_elements_into_array(@law)
    @proposal_elements = combiner.put_proposal_document_elements_into_array(@proposal)

    @actions = combiner.generate_actions(@proposal_elements)
    @old_text = combiner.render_law(@law_elements, @actions)
  end

  # AJAX

  def preview_process_document_element
    if pde = ProcessDocumentElement.find(params[:id])
      render :text => pde.content
    else
      render :text => ""
    end
  end

end
