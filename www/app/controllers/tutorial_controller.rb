class TutorialController < ApplicationController

  layout false

  def index
    @page = params[:page].to_i
  end
  
end
