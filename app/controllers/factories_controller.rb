class FactoriesController < ApplicationController
  before_action :check_docked

  def modal
    raise InvalidRequest if !params[:loader] || !params[:type]

    if params[:type] == 'item'
      render(partial: 'stations/factory/itemmodal', locals: { item: params[:loader] })
    else
      render(partial: 'stations/factory/shipmodal', locals: { key: params[:loader], value: Spaceship.get_attribute(params[:loader]) })
    end
  end

  def craft
    raise InvalidRequest if !params[:loader] || !params[:type] || !params[:amount] || !current_user.location.industrial_station?

    amount = params[:amount].to_i

    if params[:type] == 'ship'
      ressources = Spaceship.get_attribute(params[:loader], :crafting)
    elsif params[:loader].include?('equipment.')
      ressources = Item.get_attribute(params[:loader], :crafting)
    else
      raise InvalidRequest
    end
    raise InvalidRequest if !ressources || !current_user.blueprints.where(loader: params[:loader]).present?

    # Check max concurrent factory runs (100)
    if (current_user.craft_jobs.count + amount) > 100
      raise InvalidRequest.new('errors.cant_more_than_100_factory_runs')
    end

    # Check if has ressources
    ressources.each do |key, value|
      item = Item.where(loader: key, user: current_user, location: current_user.location).first
      value = value * current_user.blueprints.where(loader: params[:loader]).first.efficiency
      if !item || item.count < (value.round * amount)
        raise InvalidRequest.new('errors.not_required_material')
      end
    end

    ActiveRecord::Base.transaction do
      amount.times do
        # Delete ressources
        ressources.each do |key, value|
          value = value * current_user.blueprints.where(loader: params[:loader]).first.efficiency
          Item::RemoveFromUser.(loader: key, user: current_user, location: current_user.location, amount: value.round)
        end

        # Create CraftJob
        attrs = {
          loader: params[:loader],
          user: current_user,
          location: current_user.location
        }
        if params[:type] == 'ship'
          # Q: What time duration is :crafting_duration in?
          attrs[:completed_at] = Time.now.utc + (Spaceship.get_attribute(params[:loader], :crafting_duration) / 1440.0)
        else
          attrs[:completed_at] = Time.now.utc + (Item.get_attribute(params[:loader], :crafting_duration) / 1440.0)
        end
        CraftJob.create(**attrs)
      end
    end

    render json: {}, status: :ok
  end

  def dismantle_modal
    raise InvalidRequest unless params[:loader]

    render(partial: 'stations/factory/dismantlemodal', locals: { item: params[:loader] })
  end

  def dismantle
    raise InvalidRequest if !params[:loader] || !params[:amount] || !current_user.location.industrial_station?

    amount = params[:amount].to_i # FYI  nil.to_i == 0
    item = Item.where(loader: params[:loader], location: current_user.location, user: current_user).first
    raise InvalidRequest unless item

    # Check if trying to dismantle more than has
    raise InvalidRequest.new('errors.you_dont_have_enough_of_this') if amount > item.count

    # Get Crafting Materials and Destroy Items
    materials = item.get_attribute('crafting')

    ActiveRecord::Base.transaction do
      Item::RemoveFromUser.(loader: params[:loader], location: current_user.location, user: current_user, amount: amount)
      materials.each do |key, value|
        Item::GiveToUser.(item_id: key, location: current_user.location, user: current_user, amount: (value * amount * 0.4 * rand(0.9..1.1)).round)
      end
    end

    render json: { message: I18n.t('station.dismantling_successful') }, status: :ok
  end

end
