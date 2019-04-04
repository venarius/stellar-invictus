class BlueprintsController < ApplicationController
  before_action :check_docked

  include ApplicationHelper

  def buy
    if params[:loader] && params[:type] && current_user.location.research_station?
      if params[:type] == 'item'
        raise ArgumentError.new("Unknown Item") unless Item.get_attributes(params[:loader])
        price = Item.get_attribute(params[:loader], :price) * 20
      else
        raise ArgumentError.new("Unknown Spaceship") unless Spaceship.get_attributes(params[:loader])
        price = Spaceship.get_attribute(params[:loader], :price) * 20
      end

      if price && !current_user.has_blueprints_for?(params[:loader])
        # Check Balance
        if current_user.units < price
          render(json: { error_message: I18n.t('errors.you_dont_have_enough_credits') }, status: :bad_request)
          return
        end

        ActiveRecord::Base.transaction do
          # Give Blueprint to User
          current_user.give_blueprints_for(params[:loader], efficiency: 1.5)
          # Deduct units
          current_user.reduce_units(price)
        end

        render(json: {}, status: :ok)
        return
      end
    end
    render json: {}, status: :bad_request
  end

  def modal
    if params[:loader] && params[:type]
      if params[:type] == 'item'
        render(partial: 'stations/blueprints/itemmodal', locals: { item: params[:loader] }) && (return)
      else
        render(partial: 'stations/blueprints/shipmodal', locals: { key: params[:loader], value: Spaceship.get_attribute(params[:loader]) }) && (return)
      end
    end
    render json: {}, status: :bad_request
  end

end
