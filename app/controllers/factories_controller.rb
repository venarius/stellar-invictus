class FactoriesController < ApplicationController
  before_action :check_docked

  include ApplicationHelper

  def modal
    if params[:loader] && params[:type]
      if params[:type] == 'item'
        render(partial: 'stations/factory/itemmodal', locals: { item: params[:loader] }) && (return)
      else
        render(partial: 'stations/factory/shipmodal', locals: { key: params[:loader], value: Spaceship.ship_variables[params[:loader]] }) && (return)
      end
    end
    render json: {}, status: 400
  end

  def craft
    if params[:loader] && params[:type] && params[:amount] && current_user.location.industrial_station?

      if params[:type] == 'ship'
        ressources = Spaceship.ship_variables[params[:loader]]['crafting'] rescue nil
      elsif params[:loader].include?('equipment.')
        ressources = get_item_attribute(params[:loader], 'crafting')
      else
        render(json: {}, status: 400) && (return)
      end

      if ressources && current_user.blueprints.where(loader: params[:loader]).present?

        # Check max concurrent factory runs (100)
        render(json: { 'error_message': I18n.t('errors.cant_more_than_100_factory_runs') }, status: 400) && (return) if (CraftJob.where(user: current_user).count + params[:amount].to_i) > 100

        # Check if has ressources
        ressources.each do |key, value|
          item = Item.find_by(loader: key, user: current_user, location: current_user.location) rescue nil
          value = value * current_user.blueprints.find_by(loader: params[:loader]).efficiency
          render(json: { 'error_message': I18n.t('errors.not_required_material') }, status: 400) && (return) if !item || item.count < value.round * params[:amount].to_i
        end

        params[:amount].to_i.times do
          # Delete ressources
          ressources.each do |key, value|
            value = value * current_user.blueprints.find_by(loader: params[:loader]).efficiency
            Item.remove_from_user(loader: key, user: current_user, location: current_user.location, amount: value.round)
          end

          # Create CraftJob
          if params[:type] == 'ship'
            CraftJob.create(completion: DateTime.now + (Spaceship.ship_variables[params[:loader]]['crafting_duration'].to_f / 1440.0), loader: params[:loader], user: current_user, location: current_user.location)
          else
            CraftJob.create(completion: DateTime.now + (get_item_attribute(params[:loader], 'crafting_duration').to_f / 1440.0), loader: params[:loader], user: current_user, location: current_user.location)
          end
        end

        render(json: {}, status: 200) && (return)
      end
    end
    render json: { message: 'plub' }, status: 400
  end

  def dismantle_modal
    if params[:loader]
      render(partial: 'stations/factory/dismantlemodal', locals: { item: params[:loader] }) && (return)
    end
    render(json: {}, status: 400) && (return)
  end

  def dismantle
    if params[:loader] && params[:amount] && current_user.docked && current_user.location.industrial_station?
      amount = params[:amount].to_i rescue 0
      item = Item.find_by(loader: params[:loader], location: current_user.location, user: current_user) rescue nil

      if item
        # Check if trying to dismantle more than has
        render(json: { 'error_message': I18n.t('errors.you_dont_have_enough_of_this') }, status: 400) && (return) if amount > item.count

        # Get Crafting Materials and Destroy Items
        materials = item.get_attribute('crafting')
        Item.remove_from_user(loader: params[:loader], location: current_user.location, user: current_user, amount: amount)
        materials.each do |key, value|
          Item.give_to_user(loader: key, location: current_user.location, user: current_user, amount: (value * amount * 0.4 * rand(0.9..1.1)).round)
        end

        render(json: { message: I18n.t('station.dismantling_successful') }, status: 200) && (return)
      end
    end
    render json: {}, status: 400
  end

end
