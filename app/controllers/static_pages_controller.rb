class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, except: [:map]
  
  def about
  end
  
  def home
  end
  
  def credits
  end
  
  def nojs
  end
  
  def map
  end
end