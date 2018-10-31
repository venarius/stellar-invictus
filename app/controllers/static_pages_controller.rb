class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :redirect_if_user
  
  def about
  end
  
  def home
  end
  
  def credits
  end
  
  def nojs
  end
  
  private
  
  def redirect_if_user
    redirect_to game_path if current_user
  end
end