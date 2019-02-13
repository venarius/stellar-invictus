class StationsController < ApplicationController
  before_action :check_police, only: [:dock]
  
  include ApplicationHelper
  
  def dock
    # If user is at station and not docked
    if current_user.location.location_type == 'station' and !current_user.docked
      
      # Refuse if standing below -10
      if current_user.location.faction and current_user["reputation_#{current_user.location.faction_id}"] <= -10
        render json: {error_message: I18n.t('errors.docking_request_denied_low_standing')}, status: 400 and return
      end
      
      # Dock the user
      current_user.dock
      
      # Repair ship
      current_user.active_spaceship.update_columns(hp: current_user.active_spaceship.get_attribute('hp'))
      if current_user.fleet
        ChatChannel.broadcast_to(current_user.fleet.chat_room, method: 'update_hp_color', color: current_user.active_spaceship.get_hp_color, id: current_user.id)
      end
    end
  end
  
  def undock
    current_user.undock
  end
  
  def index
    unless current_user.docked
      redirect_to game_path and return
    end
    
    # Fallback
    if current_user.location.location_type != "station"
      current_user.update_columns(docked: false) and redirect_to game_path and return
    end
    
    # Render Tabs
    if params[:tab]
      case params[:tab]
      when 'overview'
        render partial: 'stations/overview'
      when 'missions'
        MissionGenerator.generate_missions(current_user.location_id)
        render partial: 'stations/missions'
      when 'bounty_office'
        render partial: 'stations/bounty_office'
      when 'storage'
        render partial: 'stations/storage'
      when 'factory'
        render partial: 'stations/factory'
      when 'blueprints'
        render partial: 'stations/blueprints'
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
      @global_messages = ChatMessage.includes(:user).where(chat_room: ChatRoom.where(chatroom_type: :global).first).last(10)
    end
    
    # Receive Passengers
    if current_user.location.faction and Item.where(loader: "delivery.passenger", spaceship: current_user.active_spaceship).present?
      count = 0
      Item.where(loader: "delivery.passenger", spaceship: current_user.active_spaceship).each do |passenger|
        count = count + 1
        case current_user.location.faction_id
          when 1
            current_user.update_columns(reputation_1: current_user.reputation_1 + 0.05)
          when 2
            current_user.update_columns(reputation_2: current_user.reputation_2 + 0.05)
          when 3
            current_user.update_columns(reputation_3: current_user.reputation_3 + 0.05)
        end
        passenger.destroy
      end
      ActionCable.server.broadcast("player_#{current_user.id}", method: 'notify_alert', text: I18n.t('notification.received_reputation_passengers', amount: (0.05 * count).round(2)), delay: 1000)
    end
    
  end
  
  # Ship -> Station
  def store
    if params[:loader] and params[:amount] and current_user.docked
      amount = params[:amount].to_i
      items = Item.where(spaceship: current_user.active_spaceship, loader: params[:loader], equipped: false)
      if items and amount <= items.count and amount > 0
        items.limit(amount).update_all(spaceship_id: nil, location_id: current_user.location_id, user_id: current_user.id)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  # Station -> Ship
  def load
    if params[:loader] and current_user.docked
      amount = params[:amount].to_i if params[:amount]
      
      items = Item.where(user: current_user, location: current_user.location, loader: params[:loader])
      
      render json: {}, status: 400 and return unless items
      
      if amount
        if (get_item_attribute(items.first.loader, 'weight') rescue 0) * amount > current_user.active_spaceship.get_free_weight
          render json: {'error_message': I18n.t('errors.your_ship_cant_carry_that_much')}, status: 400 and return
        end
        if items and amount <= items.count and amount > 0
          items.limit(amount).update_all(spaceship_id: current_user.active_spaceship_id, location_id: nil, user_id: nil)
          render json: {}, status: 200 and return
        end
      else
        # Check if player has enough space
        free_weight = current_user.active_spaceship.get_free_weight
        item_count = items.count
        
        count = 0
        
        items.each do |item|
          if item.get_attribute('weight') <= free_weight
            item.update_columns(spaceship_id: current_user.active_spaceship_id, location_id: nil, user_id: nil)
            free_weight = free_weight - item.get_attribute('weight')
            count = count + 1
          end
        end
        
        if count > 0
          if item_count == count
            render json: {}, status: 200 and return
          else
            render json: {amount: item_count - count}, status: 200 and return
          end
        else
          render json: {error_message: I18n.t('errors.your_ship_cant_carry_that_much')}, status: 400 and return
        end
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
      if ship.location_id == current_user.location_id || ship == current_user.active_spaceship
        @user_ships << ship 
      end
    end
    @user_ships
  end
end