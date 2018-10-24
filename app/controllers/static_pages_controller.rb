class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!
  
  def about
  end
  
  def home
  end
  
  def credits
  end
  
  def nojs
  end
end