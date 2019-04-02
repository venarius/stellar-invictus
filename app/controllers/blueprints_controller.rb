class BlueprintsController < ApplicationController
  before_action :check_docked

  include ApplicationHelper

  def buy
    if params[:loader] && params[:type] && current_user.location.research_station?
      if params[:type] == 'item'
        price = Item.get_attribute(params[:loader], :price) * 20 rescue nil
      else
        price = Spaceship.get_attribute(params[:loader], :price) * 20 rescue nil
      end

      if price && current_user.blueprints.where(loader: params[:loader]).empty?
        # Check Balance
        render(json: { 'error_message': I18n.t('errors.you_dont_have_enough_credits') }, status: 400) && (return) unless current_user.units >= price

        # Give Blueprint to User
        Blueprint.create(user: current_user, loader: params[:loader], efficiency: 1.5)

        # Deduct units
        current_user.reduce_units(price)

        render(json: {}, status: 200) && (return)
      end
    end
    render json: {}, status: 400
  end

  def modal
    if params[:loader] && params[:type]
      if params[:type] == 'item'
        render(partial: 'stations/blueprints/itemmodal', locals: { item: params[:loader] }) && (return)
      else
        render(partial: 'stations/blueprints/shipmodal', locals: { key: params[:loader], value: Spaceship.get_attribute(params[:loader]) }) && (return)
      end
    end
    render json: {}, status: 400
  end

end
