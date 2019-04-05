class ShipsController < ApplicationController
  def index
    @items = current_user.active_spaceship.get_items
    @active_spaceship = current_user.active_spaceship
  end

  def activate
    spaceship = Spaceship.ensure(params[:id])
    if spaceship && (spaceship.user == current_user) && current_user.docked && (spaceship.location == current_user.location)
      current_user.active_spaceship.update_columns(location_id: current_user.location.id)
      current_user.update_columns(active_spaceship_id: spaceship.id)
      spaceship.update_columns(location_id: nil)
      render(json: {}, status: :ok) && (return)
    end
    render json: {}, status: :bad_request
  end

  def target
    user = User.ensure(params[:id])
    if user && user.can_be_attacked && (user.location == current_user.location) && current_user.can_be_attacked && (current_user.target != user)
      TargetingWorker.perform_async(current_user.id, user.id)
      render json: { time: current_user.active_spaceship.get_target_time }, status: :ok
    else
      render json: {}, status: :bad_request
    end
  end

  def untarget
    if current_user.target
      current_user.target.broadcast(:stopping_target, name: current_user.full_name)
      current_user.update_columns(target_id: nil, is_attacking: false)
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
    if params[:loader] && params[:amount] && current_user.can_be_attacked
      amount = params[:amount].to_i

      if amount && (amount > 0)
        # check amount
        render(json: { error_message: I18n.t('errors.you_dont_have_enough_of_this') }, status: :bad_request) && (return) if Item.find_by(loader: params[:loader], spaceship: current_user.active_spaceship, equipped: false).count < amount

        EjectCargoWorker.perform_async(current_user.id, params[:loader], amount)
        render(json: {}, status: :ok) && (return)
      else
        render(json: { error_message: I18n.t('errors.invalid_amount') }, status: :bad_request) && (return)
      end
    end
    render json: {}, status: :bad_request
  end

  def insure
    if params[:id]
      ship = Spaceship.ensure(params[:id])
      if ship && (ship.user == current_user) && !ship.insured? && current_user.docked?
        price = (Spaceship.get_attribute(ship.name, :price) / 2).round

        # check that they have enough units
        if price > current_user.units
          render(json: { 'error_message': I18n.t('errors.you_dont_have_enough_credits') }, status: :bad_request)
          return
        end

        # Insure & charge them
        ActiveRecord::Base.transaction do
          ship.update_columns(insured: true)
          current_user.reduce_units(price)
        end

        render(json: {}, status: :ok) && (return)
      end
    end
    render json: {}, status: :bad_request
  end

  def custom_name
    if params[:name] && params[:id]
      ship = Spaceship.ensure(params[:id])

      if ship && (ship.user == current_user)
        params[:name] = nil if params[:name].blank?
        if ship.update(custom_name: params[:name])
          render(json: {}, status: :ok)
          return
        end
      end
    end
    render json: {}, status: :bad_request
  end

  def upgrade_modal
    render partial: 'ships/upgrade_modal', locals: { ship: current_user.active_spaceship }
  end

  def upgrade
    if current_user.docked? && current_user.active_spaceship && (current_user.active_spaceship.level < 5)
      # Check required materials
      current_user.active_spaceship.get_attribute('upgrade.ressources').each do |key, value|
        item = current_user.items.find_by(loader: key, location: current_user.location)
        if !item || item.count < value
          render(json: { 'error_message': I18n.t('errors.not_required_material') }, status: :bad_request)
          return
        end
      end

      # Delete ressources
      current_user.active_spaceship.get_attribute('upgrade.ressources').each do |key, value|
        Item::RemoveFromUser.(loader: key, user: current_user, location: current_user.location, amount: value)
      end

      current_user.active_spaceship.update_columns(level: current_user.active_spaceship.level + 1)
      current_user.active_spaceship.repair
      render(json: {}, status: :ok)
      return
    end
    render json: {}, status: :bad_request
  end

end
