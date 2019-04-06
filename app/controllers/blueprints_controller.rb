class BlueprintsController < ApplicationController
  before_action :check_docked

  def buy
    raise InvalidRequest unless params[:loader].present?
    raise InvalidRequest unless current_user.location.research_station?
    raise InvalidRequest unless %[item ship].include?(params[:type])
    raise InvalidRequest if current_user.has_blueprints_for?(params[:loader])

    klass = nil
    case params[:type]
    when 'item' then klass = Item
    when 'ship' then klass = Spaceship
    end
    raise ArgumentError.new("Unknown #{klass}") unless klass.get_attributes(params[:loader])
    price = klass.get_attribute(params[:loader], :price) * 20

    raise InvalidRequest.new('errors.you_dont_have_enough_credits') if current_user.units < price

    ActiveRecord::Base.transaction do
      current_user.give_blueprints_for(params[:loader], efficiency: 1.5)
      current_user.reduce_units(price)
    end

    render json: {}, status: :ok
  end

  def modal
    raise InvalidRequest if !params[:loader].present? || !params[:type].present?
    if params[:type] == 'item'
      render partial: 'stations/blueprints/itemmodal',
             locals: { item: params[:loader] },
             status: :ok
    else
      render partial: 'stations/blueprints/shipmodal',
             locals: { key: params[:loader], value: Spaceship.get_attribute(params[:loader]) },
             status: :ok
    end
  end

end
