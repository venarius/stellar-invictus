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
    if params[:id] and params[:amount]
      amount = params[:amount].to_i
      listing = MarketListing.find(params[:id]) rescue nil
      if listing and listing.location == current_user.location and amount >= 1
        
        # Check Amount
        render json: {'error_message': I18n.t('errors.you_cant_buy_that_much')}, status: 400 and return if amount > listing.amount
        
        # Check Balance
        render json: {'error_message': I18n.t('errors.you_dont_have_enough_credits')}, status: 400 and return unless current_user.units >= listing.price * amount
        
        # If listing is item -> else..
        if listing.item?
          amount.times do
            Item.create(location: current_user.location, user: current_user, loader: listing.loader, equipped: false)
          end
        else
          
          # Check if met requirements
          ship = SHIP_VARIABLES[listing.loader]
          if ship['faction'] and ship['reputation_requirement']
            rank = Faction.find(ship['faction']).get_rank(current_user)
            render json: {'error_message': I18n.t('errors.you_dont_have_the_required_reputation')}, status: 400 and return unless rank and rank['type'] >= ship['reputation_requirement']
          end
          
          amount.times do
            Spaceship.create(location: current_user.location, user: current_user, name: listing.loader, hp: SHIP_VARIABLES[listing.loader]['hp'])
          end
        end
        
        # Deduct units
        current_user.reduce_units(listing.price * amount)
        
        # Destroy Listing
        new_amount = listing.amount - amount
        listing.update_columns(amount: new_amount)
        listing.destroy if new_amount == 0
        
        render json: {'new_amount': new_amount}, status: 200 and return
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
    quantity = params[:quantity].to_i
    if price != nil
      
      # If type == item -> else..
      if params[:type] == "item"
        # Check if user tries to sell more
        render json: {'error_message': I18n.t('errors.you_dont_have_enough_of_this')}, status: 400 and return if Item.where(loader: params[:loader], user: current_user, location: current_user.location).count < quantity
        
        # Destroy items
        Item.where(loader: params[:loader], user: current_user, location: current_user.location).limit(quantity).delete_all
        
      elsif params[:type] == "ship" and params[:id] and quantity == 1
      
        ship = Spaceship.find(params[:id].to_i) rescue nil
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
      current_user.give_units(price)
      
      # Generate Listing
      fill_listing = MarketListing.where(loader: params[:loader], location: current_user.location).where("amount < 20").first rescue nil
      if fill_listing
        fill_listing.update_columns(amount: fill_listing.amount + quantity)
      else
        rabat = rand(0.8..1.2)
        if params[:type] == "item"
          MarketListing.create(loader: params[:loader], listing_type: 'item', location: current_user.location, price: (get_item_attribute(params[:loader], 'price') * rabat * rand(0.98..1.02)).round, amount: quantity)
        elsif params[:type] == "ship"
          MarketListing.create(loader: params[:loader], listing_type: 'ship', location: current_user.location, price: (SHIP_VARIABLES[params[:loader]]['price'] * rabat * rand(0.98..1.02)).round, amount: quantity)
        end
      end
      
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  private
  
  def generate_price(loader, type, quantity)
    if loader and type
      listings = MarketListing.where(loader: loader, location: current_user.location).count
      if quantity and quantity.to_i > 0
        math = 0
        quantity.to_i.times do
          if type == "item"
            
            if MarketListing.where(loader: loader, location: current_user.location).empty?
              price = get_item_attribute(loader, 'price') rescue nil
            else
              price = (MarketListing.where(loader: loader, location: current_user.location).order('price ASC').first.price * 0.98) rescue nil
            end
            
            # Customization
            location = current_user.location
            if location.industrial_station?
              price = price * 0.75 if loader.include?("equipment.")
            elsif location.warfare_plant?
              price = price * 0.75 if loader.include?("equipment.weapons")
            elsif location.mining_station?
              price = price * 0.75 if loader.include?("asteroid.")
            end
            
          else
            if MarketListing.where(loader: loader, location: current_user.location).empty?
              price = SHIP_VARIABLES[loader]['price'] rescue nil
            else
              price = (MarketListing.where(loader: loader, location: current_user.location).order('price ASC').first.price * 0.98) rescue nil
            end
          end
          listings = 1 if listings == 0
          math = math + (price rescue nil / (1.05 ** listings)).round rescue nil
        end
        return math rescue nil
      end
    end
  end
  
end