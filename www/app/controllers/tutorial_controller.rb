class TutorialController < ApplicationController

  layout 'colorbox'

  def index
    @page = params[:page].to_i
  end
  
end
