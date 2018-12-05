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
      if listing and listing.location == current_user.location and current_user.units >= listing.price
        if listing.item?
          Item.create(location: current_user.location, user: current_user, loader: listing.loader, equipped: false)
        else
          Spaceship.create(location: current_user.location, user: current_user, name: listing.loader, hp: SHIP_VARIABLES[listing.loader]['hp'])
        end
        current_user.update_columns(units: current_user.units - listing.price)
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
    if price != nil and Item.where(loader: params[:loader], user: current_user, location: current_user.location).count >= params[:quantity].to_i
      Item.where(loader: params[:loader], user: current_user, location: current_user.location).limit(params[:quantity].to_i).destroy_all
      current_user.update_columns(units: current_user.units + price)
      
      # Generate Listing
      listing = MarketListing.where(loader: params[:loader], location: current_user.location).first rescue nil
      if listing
        (params[:quantity].to_i).times do
          MarketListing.create(loader: params[:loader], listing_type: 'item', location: current_user.location, price: (listing.price * rand(0.95..1.05)).round)
        end
      else
        rabat = rand(0.8..1.2)
        (params[:quantity].to_i).times do
          MarketListing.create(loader: params[:loader], listing_type: 'item', location: current_user.location, price: (get_item_attribute(params[:loader], 'price') * rabat * rand(0.95..1.05)).round)
        end
      end
      
      render json: {}, status: 200
    else
      render json: {}, status: 400
    end
  end
  
  private
  
  def check_docked
    render json: {}, status: 400 and return unless current_user.docked
  end
  
  def generate_price(loader, type, quantity)
    if loader and type
      if type == "item"
        listings = MarketListing.where(loader: loader, location: current_user.location).count
        if quantity and quantity.to_i > 1
          return ((get_item_attribute(loader, 'price') * quantity.to_i) * 0.9).round rescue nil
        else
          return (get_item_attribute(loader, 'price') * 0.9).round rescue nil
        end
      end
    end
  end
  
end