class ShipsController < ApplicationController
  def index
    @items = current_user.active_spaceship.get_items
    @active_spaceship = current_user.active_spaceship
  end

  def activate
    spaceship = Spaceship.ensure(params[:id])
    raise InvalidRequest if !spaceship || (spaceship.user_id != current_user.id) || (spaceship.location_id != current_user.location_id) || !current_user.docked?

    current_user.active_spaceship.update(location_id: current_user.location.id)
    current_user.update(active_spaceship_id: spaceship.id)
    spaceship.update(location_id: nil)

    render json: {}, status: :ok
  end

  def target
    user = User.ensure(params[:id])
    raise InvalidRequest if !user || !user.can_be_attacked? || (user.location_id != current_user.location_id) || !current_user.can_be_attacked? || (current_user.target_id == user.id)

    TargetingWorker.perform_async(current_user.id, user.id)
    render json: { time: current_user.active_spaceship.get_target_time }, status: :ok
  end

  def untarget
    if current_user.target
      current_user.target.broadcast(:stopping_target, name: current_user.full_name)
      current_user.update(target_id: nil, is_attacking: false)
      current_user.active_spaceship.deactivate_equipment
    end
    render json: {}, status: :ok
  end

  def cargohold
    var1 = current_user.items.where(spaceship: nil, structure: nil).pluck(:location_id)
    var2 = current_user.spaceships.pluck(:location_id)
    locations = (var1 + var2).uniq.compact
    render partial: 'ships/cargohold', locals: { items: current_user.active_spaceship.get_items(true), locations: locations }
  end

  def info
    if params[:name]
      value = Spaceship.get_attribute(params[:name])
      render partial: 'ships/info', locals: { value: value, key: params[:name] }
    end
  end

  def eject_cargo
    amount = params[:amount].to_i
    raise InvalidRequest.new('errors.invalid_amount') if amount <= 0
    raise InvalidRequest if !params[:loader] || !current_user.can_be_attacked?

    # check amount
    if Item.where(loader: params[:loader], spaceship: current_user.active_spaceship, equipped: false).first.count < amount
      raise InvalidRequest.new('errors.you_dont_have_enough_of_this')
    end

    EjectCargoWorker.perform_async(current_user.id, params[:loader], amount)

    render json: {}, status: :ok
  end

  def insure
    ship = Spaceship.ensure(params[:id])
    raise InvalidRequest if !ship || ship.insured? || (ship.user_id != current_user.id) || !current_user.docked?

    price = (Spaceship.get_attribute(ship.name, :price) / 2).round

    # check that they have enough units
    raise InvalidRequest.new('errors.you_dont_have_enough_credits') if price > current_user.units

    # Insure & charge them
    ActiveRecord::Base.transaction do
      ship.update(insured: true)
      current_user.reduce_units(price)
    end

    render json: {}, status: :ok
  end

  def custom_name
    ship = Spaceship.ensure(params[:id])
    raise InvalidRequest if !ship || !params[:name] || (ship.user_id != current_user.id)

    params[:name] = nil if params[:name].blank?
    if !ship.update(custom_name: params[:name])
      raise InvalidRequest
    end

    render json: {}, status: :ok
   end

  def upgrade_modal
    render partial: 'ships/upgrade_modal', locals: { ship: current_user.active_spaceship }
  end

  def upgrade
    raise InvalidRequest if !current_user.docked? || !current_user.active_spaceshp || current_user.active_spaceship.level >= 5

    # Check required materials
    current_user.active_spaceship.get_attribute('upgrade.ressources').each do |key, value|
      item = current_user.items.where(loader: key, location: current_user.location).first
      raise InvalidRequest.new('errors.not_required_material') if !item || item.count < value
    end

    # Delete ressources
    current_user.active_spaceship.get_attribute('upgrade.ressources').each do |key, value|
      Item::RemoveFromUser.(loader: key, user: current_user, location: current_user.location, amount: value)
    end

    current_user.active_spaceship.update(level: current_user.active_spaceship.level + 1)
    current_user.active_spaceship.repair

    render json: {}, status: :ok
  end

end
