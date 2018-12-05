class MarketController < ApplicationController
  before_action :check_docked
  
  include ApplicationHelper
  
  def list
    if params[:loader]
      listings = MarketListing.where(location: current_user.location).where("loader ilike ?", "%#{params[:loader]}%")
      render partial: 'stations/market/list', locals: {market_listings: listings} and return
    end
    render json: {}, status: 400
  end
  
  def search
    if params[:search]
      listings = MarketListing.where(location: current_user.location).where("loader ilike ?", "%#{params[:search].gsub(' ', '_')}%")
      render partial: 'stations/market/list', locals: {market_listings: listings} and return
    end
    render json: {}, status: 400
  end
  
  def buy
    if params[:id]
      listing = MarketListing.find(params[:id]) rescue nil
      if listing and listing.location == current_user.location
        
        # Check Balance
        render json: {'error_message': I18n.t('errors.you_dont_have_enough_credits')}, status: 400 and return unless current_user.units >= listing.price
        
        # If listing is item -> else..
        if listing.item?
          Item.create(location: current_user.location, user: current_user, loader: listing.loader, equipped: false)
        else
          Spaceship.create(location: current_user.location, user: current_user, name: listing.loader, hp: SHIP_VARIABLES[listing.loader]['hp'])
        end
        
        # Deduct units
        current_user.update_columns(units: current_user.units - listing.price)
        
        # Destroy Listing
        listing.destroy
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def appraisal
    price = generate_price(params[:loader], params[:type], params[:quantity])
    if price != nil
      render json: {"price": price}, status: 200
    else
      render json: {}, status: 400
    end
  end
  
  def sell
    price = generate_price(params[:loader], params[:type], params[:quantity])
    if price != nil
      
      # If type == item -> else..
      if params[:type] == "item"
        # Check if user tries to sell more
        render json: {'error_message': I18n.t('errors.you_dont_have_enough_of_this')}, status: 400 and return if Item.where(loader: params[:loader], user: current_user, location: current_user.location).count < params[:quantity].to_i
        
        # Destroy items
        Item.where(loader: params[:loader], user: current_user, location: current_user.location).limit(params[:quantity].to_i).destroy_all
        
      elsif params[:type] == "ship" and params[:id]
      
        ship = Spaceship.find(params[:id].to_i)
        if ship and ship.user == current_user
          # Check if active ship
          render json: {'error_message': I18n.t('errors.you_cant_sell_active_ship')}, status: 400 and return if ship == current_user.active_spaceship
          
          # Check if ship is in current location
          if ship.location == current_user.location
            ship.destroy
          else
            render json: {}, status: 400 and return
          end
        else
          render json: {}, status: 400 and return
        end
      else
        render json: {}, status: 400 and return
      end
      
      # Deduct Units
      current_user.update_columns(units: current_user.units + price)
      
      # Generate Listing
      listing = MarketListing.where(loader: params[:loader], location: current_user.location).first rescue nil
      if listing
        (params[:quantity].to_i).times do
          MarketListing.create(loader: params[:loader], listing_type: params[:type], location: current_user.location, price: (listing.price * rand(0.95..1.05)).round)
        end
      else
        rabat = rand(0.8..1.2)
        (params[:quantity].to_i).times do
          MarketListing.create(loader: params[:loader], listing_type: params[:type], location: current_user.location, price: (get_item_attribute(params[:loader], 'price') * rabat * rand(0.95..1.05)).round)
        end
      end
      
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  private
  
  def check_docked
    render json: {}, status: 400 and return unless current_user.docked
  end
  
  def generate_price(loader, type, quantity)
    if loader and type
      listings = MarketListing.where(loader: loader, location: current_user.location).count
      if quantity and quantity.to_i > 0
        math = 0
        quantity.to_i.times do
          listings = 1 if listings == 0
          if type == "item"
            math = math + (get_item_attribute(loader, 'price') / (1.05 ** listings))
          else
            math = math + (SHIP_VARIABLES[loader]['price'] / (1.05 ** listings))
          end
          listings = listings + 1
        end
        return math.round
      end
    end
  end
  
end