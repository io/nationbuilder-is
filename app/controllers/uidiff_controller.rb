require "combiner"

class UidiffController < ApplicationController

  def index
    @proposal = ProcessDocument.find(142)
  end

  def save
    # redirect_to 
  end

  def preview
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

end
