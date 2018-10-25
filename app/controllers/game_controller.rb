class GameController < ApplicationController
   def index
      @current_user = User.includes(:system).find(current_user.id)
   end
end