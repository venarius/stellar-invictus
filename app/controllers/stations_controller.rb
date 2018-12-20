class StationsController < ApplicationController
  before_action :check_police, only: [:dock]
  
  include ApplicationHelper
  
  def dock
    # If user is at station and not docked
    if current_user.location.location_type == 'station' and !current_user.docked
      # Dock the user
      current_user.dock
      
      # Repair ship
      current_user.active_spaceship.update_columns(hp: current_user.active_spaceship.get_attribute('hp'))
    end
  end
  
  def undock
    current_user.undock
  end
  
  def index
    unless current_user.docked
      redirect_to game_path and return
    end
    
    # Render Tabs
    if params[:tab]
      case params[:tab]
      when 'overview'
        render partial: 'stations/overview'
      when 'missions'
        MissionGenerator.generate_missions(current_user.location.id)
        render partial: 'stations/missions'
      when 'bounty_office'
        render partial: 'stations/bounty_office'
      when 'storage'
        render partial: 'stations/storage'
      when 'factory'
        render partial: 'stations/factory'
      when 'market'
        render partial: 'stations/market', locals: {market_listings: MarketListing.where(location: current_user.location).map(&:loader)}
      when 'my_ships'
        render partial: 'stations/my_ships', locals: {user_ships: get_user_ships}
      when 'active_ship'
        render partial: 'stations/active_ship', locals: {active_spaceship: current_user.active_spaceship}
      end
      return
      
    else
      
      # Set some variables for the view
      @system_users = User.where("online > 0").where(system: current_user.system)
      @current_user = User.includes(:system).find(current_user.id)
      @local_messages = ChatMessage.includes(:user).where(chat_room: ChatRoom.find_by(location: current_user.location)).last(10)
      @global_messages = ChatMessage.includes(:user).where(chat_room: ChatRoom.first).last(10)
    end
  end
  
  # Ship -> Station
  def store
    if params[:loader] and params[:amount] and current_user.docked
      amount = params[:amount].to_i
      items = Item.where(spaceship: current_user.active_spaceship, loader: params[:loader])
      if items and amount <= items.count and amount > 0
        items.limit(amount).update_all(spaceship_id: nil, location_id: current_user.location.id, user_id: current_user.id, equipped: false)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  # Station -> Ship
  def load
    if params[:loader] and params[:amount] and current_user.docked
      amount = params[:amount].to_i
      items = Item.where(user: current_user, location: current_user.location, loader: params[:loader])
      if get_item_attribute(items.first.loader, 'weight') * amount > current_user.active_spaceship.get_free_weight
        render json: {'error_message': I18n.t('errors.your_ship_cant_carry_that_much')}, status: 400 and return
      end
      if items and amount <= items.count and amount > 0
        items.limit(amount).update_all(spaceship_id: current_user.active_spaceship.id, location_id: nil, user_id: nil)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  private
  
  def check_police
    police = Npc.where(target: current_user.id, npc_type: 'police') rescue nil
    if police.count > 0
      render json: {'error_message' => I18n.t('errors.police_inbound')}, status: 400 and return
    end
  end
  
  def get_user_ships
    @user_ships = []
    Spaceship.where(user: current_user).includes(:location, :user).each do |ship|
      if ship.location_id == current_user.location.id || ship == current_user.active_spaceship
        @user_ships << ship 
      end
    end
    @user_ships
  end
end