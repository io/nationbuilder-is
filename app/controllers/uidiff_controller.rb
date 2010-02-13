class UidiffController < ApplicationController

  def index
  end

  def preview
    @original_law = Priority.find(45)
  end

end
