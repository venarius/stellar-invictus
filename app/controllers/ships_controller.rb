class ShipsController < ApplicationController
  def index
  end
  
  def activate
    spaceship = Spaceship.find(params[:id]) rescue nil
    if spaceship and spaceship.user == current_user
      current_user.active_spaceship_id = spaceship.id
      current_user.save(validate: false)
      render partial: '/stations/my_ships'
    end
  end
end