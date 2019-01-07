class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :credits, :nojs]
  skip_before_action :redirect_if_no_faction, only: [:home, :credits, :nojs]
  
  def home
  end
  
  def credits
  end
  
  def nojs
  end
  
  def map
  end
end