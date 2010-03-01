require "combiner"

class UidiffController < ApplicationController

  def index
    redirect_to :action => :new
  end

  def new
    @proposal = ProcessDocument.find(params[:id])
  end

  def edit
    @generated_proposal = GeneratedProposal.find(params[:id])
    @proposal = @generated_proposal.process_document
  end

  def save
    elements = []
    @proposal = ProcessDocument.find(params[:process_document][:id])

    # Get the list of document elements from the proposal
    @proposal.process_document_elements.articles.each do |element|
      change_elements = params[:change_elements].blank? ? [] : ProcessDocumentElement.all(:conditions => "parent_id = #{element.id} and id in (#{params[:change_elements]})")
      change_elements.empty? ? elements << element.children.first : elements << change_elements.first
    end

    # Check if an identical merge has been saved before
    for gp in @proposal.generated_proposals
      found = gp.generated_proposal_elements.all(:conditions => "process_document_element_id in (#{elements.map{|e|e.id}.join(",")})")
      redirect_to(:action => :preview, :id => gp) and return if found.size == elements.size
    end

    # Create new generated proposal
    gp = GeneratedProposal.new({
      :user => current_user,
      :process_document => @proposal
    })
    
    # Get the list of document elements from the proposal
    for element in elements
      gp.generated_proposal_elements.build({
        :process_document_element => element
      })
    end
    
    gp.save
    
    redirect_to(:action => :preview, :id => gp)
  end

  def preview
    # Get all objects
    @proposal = GeneratedProposal.find(params[:id])
    @priority = @proposal.process_document.priority_process.priority

    # Find the original laws
    @law = nil
    @priority.priority_processes.each do |pp|
      law = pp.process_documents.first(:conditions => "external_link like '%/lagas/%'")
      @law = law unless law.blank?
    end

    # Load the combiner
    @combiner = Combiner.new

    # Do not continue if this portion has been cached
    unless read_fragment({:id => params[:id]})
      # Generate arrays with the information required for the merge
      @law_elements = @combiner.put_law_document_elements_into_array(@law)
      @proposal_elements = @combiner.put_generated_proposal_document_elements_into_array(@proposal)

      # Merge the proposals with the original laws
      @actions = @combiner.generate_actions(@proposal_elements)
      @old_text = @combiner.render_law(@law_elements, @actions)
    end
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
