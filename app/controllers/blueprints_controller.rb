class BlueprintsController < ApplicationController
  before_action :check_docked
  
  include ApplicationHelper
  
  def buy
    if params[:loader] and params[:type] and current_user.location.research_station?
      if params[:type] == 'item'
        price = get_item_attribute(params[:loader], 'price') * 20 rescue nil
      else
        price = SHIP_VARIABLES[params[:loader]]['price'] * 20 rescue nil
      end
      
      if price and current_user.blueprints.where(loader: params[:loader]).empty?
        # Check Balance
        render json: {'error_message': I18n.t('errors.you_dont_have_enough_credits')}, status: 400 and return unless current_user.units >= price
        
        # Give Blueprint to User
        Blueprint.create(user: current_user, loader: params[:loader], efficiency: 1.5)
        
        # Deduct units
        current_user.reduce_units(price)
        
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def modal
    if params[:loader] and params[:type]
      if params[:type] == 'item'
        render partial: 'stations/blueprints/itemmodal', locals: {item: params[:loader]} and return
      else
        render partial: 'stations/blueprints/shipmodal', locals: {key: params[:loader], value: SHIP_VARIABLES[params[:loader]]} and return
      end
    end
    render json: {}, status: 400
  end
  
end