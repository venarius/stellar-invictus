class StationsController < ApplicationController
  before_action :check_police, only: [:dock]

  include ApplicationHelper

  def dock
    # If user is at station and not docked
    if (current_user.location.station?) && current_user.can_be_attacked

      # Refuse if standing below -10
      if current_user.location.faction && (current_user["reputation_#{current_user.location.faction_id}"] <= -10)
        render(json: { error_message: I18n.t('errors.docking_request_denied_low_standing') }, status: :bad_request) && (return)
      end

      # Dock the user
      current_user.dock

      # Repair ship
      current_user.active_spaceship.repair
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
      redirect_to(game_path)
      return
    end

    # Fallback
    if !current_user.location.station?
      current_user.update(docked: false)
      redirect_to(game_path)
      return
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
      when 'casino'
        render partial: 'stations/casino'
      when 'market'
        render partial: 'stations/market', locals: { market_listings: MarketListing.where(location: current_user.location).map(&:loader) }
      when 'my_ships'
        render partial: 'stations/my_ships', locals: { user_ships: get_user_ships }
      when 'active_ship'
        render partial: 'stations/active_ship', locals: { active_spaceship: current_user.active_spaceship }
      end

      return
    end

    # Receive Passengers
    if current_user.location.faction && Item.where(loader: "delivery.passenger", spaceship: current_user.active_spaceship).present?
      item = Item.where(loader: "delivery.passenger", spaceship: current_user.active_spaceship).first
      case current_user.location.faction_id
      when 1
        current_user.update(reputation_1: current_user.reputation_1 + 0.05 * item.count)
      when 2
        current_user.update(reputation_2: current_user.reputation_2 + 0.05 * item.count)
      when 3
        current_user.update(reputation_3: current_user.reputation_3 + 0.05 * item.count)
      end
      current_user.broadcast(:notify_alert,
        text: I18n.t('notification.received_reputation_passengers', amount: (0.05 * item.count).round(2)),
        delay: 1000
      )
      item.destroy
    end

  end

  # Ship -> Station
  def store
    if params[:loader] && params[:amount] && current_user.docked
      amount = params[:amount].to_i
      item = Item.where(spaceship: current_user.active_spaceship, loader: params[:loader], equipped: false).first
      if item && (amount <= item.count) && (amount > 0)
        Item::GiveToStation.(loader: params[:loader], user: current_user, amount: amount)
        render(json: {}, status: :ok) && (return)
      end
    end
    render json: {}, status: :bad_request
  end

  # Station -> Ship
  def load
    if params[:loader] && current_user.docked
      amount = params[:amount].to_i if params[:amount]

      item = Item.where(user: current_user, location: current_user.location, loader: params[:loader]).first

      render(json: {}, status: :bad_request) && (return) unless item

      if amount
        if (item.get_attribute('weight') rescue 0) * amount > current_user.active_spaceship.get_free_weight
          render(json: { 'error_message': I18n.t('errors.your_ship_cant_carry_that_much') }, status: :bad_request) && (return)
        end
        render(json: { 'error_message': I18n.t('errors.you_dont_have_enough_of_this') }, status: :bad_request) && (return) if item.count < amount
        if item && (amount <= item.count) && (amount > 0)
          Item::GiveToShip.(user: current_user, loader: params[:loader], amount: amount)
          render(json: {}, status: :ok) && (return)
        end
      else
        # Check if player has enough space
        free_weight = current_user.active_spaceship.get_free_weight
        item_count = item.count

        count = 0

        if item.get_attribute('weight') <= free_weight
          count = (free_weight / item.get_attribute('weight')).round
          count = item.count if count > item.count
          Item::GiveToShip.(user: current_user, loader: params[:loader], amount: count)
          free_weight = free_weight - item.get_attribute('weight') * count
        end

        if count > 0
          if item_count == count
            render(json: {}, status: :ok) && (return)
          else
            render(json: { amount: item_count - count }, status: :ok) && (return)
          end
        else
          render(json: { error_message: I18n.t('errors.your_ship_cant_carry_that_much') }, status: :bad_request) && (return)
        end
      end
    end
    render json: {}, status: :bad_request
  end

  def dice_roll
    if params[:bet] && params[:roll_under] && current_user.docked && current_user.location.trillium_casino?
      bet = params[:bet].to_i rescue 0
      roll_under = params[:roll_under].to_i rescue 0

      # Check Bet Amount
      render(json: { 'error_message': I18n.t('errors.you_dont_have_enough_credits') }, status: :bad_request) && (return) unless current_user.units >= bet

      # Check min Bet
      render(json: { 'error_message': I18n.t('errors.minimum_bet_is_10') }, status: :bad_request) && (return) unless bet >= 10

      # Check max bet
      render(json: { 'error_message': I18n.t('errors.maximum_bet_is_100k') }, status: :bad_request) && (return) unless bet <= 100000

      if (roll_under >= 5) && (roll_under <= 95)
        current_user.reduce_units(bet)
        roll = rand(0..100)

        if roll < roll_under
          current_user.give_units((bet * (95.0 / roll_under)).round)
          render(json: { win: true, time: DateTime.now().strftime("%H:%M"), roll: roll, bet: bet, payout: (bet * (95.0 / roll_under)).round, units: current_user.reload.units, message: I18n.t('casino.won_credits', credits: (bet * (95.0 / roll_under)).round) }, status: :ok) && (return)
        else
          render(json: { win: false, time: DateTime.now().strftime("%H:%M"), roll: roll, bet: bet, payout: 0, units: current_user.reload.units, message: I18n.t('casino.lost_credits', credits: bet) }, status: :ok) && (return)
        end
      end
    end
    render json: {}, status: :bad_request
  end

  private

  def check_police
    if Npc.police.targeting_user(current_user).exists?
      render(json: { 'error_message' => I18n.t('errors.police_inbound') }, status: :bad_request) && (return)
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
