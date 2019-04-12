class StationsController < ApplicationController
  def dock
    raise InvalidRequest.new('errors.police_inbound') if police_inbound?
    location = current_user.location
    raise InvalidRequest if !location.station? || !current_user.can_be_attacked?

    # Refuse if standing below -10
    if location.faction && (current_user["reputation_#{location.faction_id}"] <= -10)
      raise InvalidRequest.new('errors.docking_request_denied_low_standing')
    end

    # Dock the user
    current_user.dock

    # Repair ship
    current_user.active_spaceship.repair
    if current_user.fleet
      ChatChannel.broadcast_to(current_user.fleet.chat_room,
        method: 'update_hp_color',
        color: current_user.active_spaceship.get_hp_color,
        id: current_user.id
      )
    end
  end

  def undock
    current_user.undock
  end

  def index
    raise RedirectRequest.new(game_path) unless current_user.docked?

    # Fallback
    if !current_user.location.station?
      current_user.update(docked: false)
      raise RedirectRequest.new(game_path)
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
    if current_user.location.faction && Item.where(loader: 'delivery.passenger', spaceship: current_user.active_spaceship).present?
      item = Item.where(loader: 'delivery.passenger', spaceship: current_user.active_spaceship).first
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
    raise InvalidRequest unless params[:loader]
    amount = params[:amount].to_i
    raise InvalidRequest if (amount <= 0) || !current_user.docked?

    item = Item.where(spaceship: current_user.active_spaceship, loader: params[:loader], equipped: false).first
    raise InvalidRequest if !item || (amount > item.count)

    Item::GiveToStation.(loader: params[:loader], user: current_user, amount: amount)

    render json: {}, status: :ok
  end

  # Station -> Ship
  def load
    raise InvalidRequest if !params[:loader] || !current_user.docked?
    json_result = {}

    item = Item.where(user: current_user, location: current_user.location, loader: params[:loader]).first
    raise InvalidRequest unless item

    if params[:amount]
      amount = params[:amount].to_i
      raise InvalidRequest unless amount > 0

      if (item.get_attribute('weight', default: 0) * amount) > current_user.active_spaceship.get_free_weight
        raise InvalidRequest.new('errors.your_ship_cant_carry_that_much')
      end
      raise InvalidRequest.new('errors.you_dont_have_enough_of_this') unless amount <= item.count

      Item::GiveToShip.(user: current_user, loader: params[:loader], amount: amount)
    else # No amount means all (apparently)
      # Check if player has enough space
      free_weight = current_user.active_spaceship.get_free_weight
      item_count = item.count

      count = 0
      if item.get_attribute('weight') <= free_weight
        count = (free_weight / item.get_attribute('weight')).round
        count = [count, item.count].min
        Item::GiveToShip.(user: current_user, loader: params[:loader], amount: count)
        free_weight -= item.get_attribute('weight') * count
      end
      raise InvalidRequest.new('errors.your_ship_cant_carry_that_much') if count == 0

      if item_count != count
        json_result = { amount: item_count - count }
      end
    end

    render json: json_result, status: :ok
  end

  def dice_roll
    raise InvalidRequest if !params[:bet] || !params[:roll_under] || !current_user.docked? || !current_user.location.trillium_casino?

    bet = params[:bet].to_i
    roll_under = params[:roll_under].to_i

    # Check Bet Amount
    raise InvalidRequest.new('errors.you_dont_have_enough_credits') unless current_user.units >= bet

    # Check min Bet
    raise InvalidRequest.new('errors.minimum_bet_is_10') unless bet >= 10

    # Check max bet
    raise InvalidRequest.new('errors.maximum_bet_is_100k') unless bet <= 100000

    json_result = {}
    if (roll_under >= 5) && (roll_under <= 95)
      current_user.reduce_units(bet)
      roll = rand(0..100)

      json_result = {
        time: DateTime.now().strftime('%H:%M'),
        roll: roll,
        bet: bet,
        units: current_user.reload.units,
      }
      if roll < roll_under
        payout = (bet * (95.0 / roll_under)).round
        current_user.give_units(payout)
        json_result.merge!(
          win: true,
          payout: payout,
          message: I18n.t('casino.won_credits', credits: payout)
        )
      else
        json_result.merge!(
          win: false,
          payout: 0,
          message: I18n.t('casino.lost_credits', credits: bet)
        )
      end
    end

    render json: json_result, status: :ok
  end

  private

  def get_user_ships
    @user_ships = []
    Spaceship.where(user: current_user).includes(:location, :user).each do |ship|
      if ship.location_id == current_user.location_id || ship == current_user.active_spaceship
        @user_ships << ship
      end
    end
    @user_ships
  end

  def police_inbound?
    Npc.police.targeting_user(current_user).exists?
  end
end
