class MarketController < ApplicationController
  before_action :check_docked
  
  include ApplicationHelper
  
  def list
    if params[:loader]
      listings = MarketListing.where(location: current_user.location).where("loader ilike ?", "%#{params[:loader]}%")
      render partial: 'stations/market/list', locals: {market_listings: listings, can_create_buy_order: current_user.location.player_market} and return
    end
    render json: {}, status: 400
  end
  
  def search
    if params[:search]
      
      listings = MarketListing.where(location: current_user.location).where("loader ilike ?", "%#{params[:search].gsub(' ', '_')}%")
      render partial: 'stations/market/list', locals: {market_listings: listings, can_create_buy_order: false} and return
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
        render json: {'error_message': I18n.t('errors.you_dont_have_enough_credits')}, status: 400 and return unless current_user.reload.units >= listing.price * amount
        
        # If listing is item -> else..
        if listing.item?
          Item.give_to_user({location: current_user.location, user: current_user, loader: listing.loader, amount: amount})
        else
          
          # Check if met requirements
          ship = Spaceship.ship_variables[listing.loader]
          if ship['faction'] and ship['reputation_requirement']
            rank = Faction.find(ship['faction']).get_rank(current_user)
            render json: {'error_message': I18n.t('errors.you_dont_have_the_required_reputation')}, status: 400 and return unless rank and rank['type'] >= ship['reputation_requirement']
          end
          
          amount.times do
            Spaceship.create(location: current_user.location, user: current_user, name: listing.loader, hp: Spaceship.ship_variables[listing.loader]['hp'])
          end
        end
        
        # Deduct units
        current_user.reduce_units(listing.price * amount)
        
        # If listing belonged to user -> give 95% of price to user and inform
        if listing.user
          listing.user.give_units(listing.price * amount * 0.95)
          if listing.item?
            ActionCable.server.broadcast("player_#{listing.user_id}", method: 'notify_info', text: I18n.t('notification.someone_bought', amount: amount, name: get_item_attribute(listing.loader, "name")))
          else
            ActionCable.server.broadcast("player_#{listing.user_id}", method: 'notify_info', text: I18n.t('notification.someone_bought', amount: amount, name: listing.loader))
          end
          ActionCable.server.broadcast("player_#{listing.user_id}", method: 'refresh_player_info')
        end
        
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
    
    # check if player market -> else generate price
    player_market = current_user.location.player_market 
    if player_market 
      price = params[:price].to_i rescue nil
    else
      price = generate_price(params[:loader], params[:type], params[:quantity])
    end
    
    quantity = params[:quantity].to_i
    if price != nil
      
      # If type == item -> else..
      if params[:type] == "item"
        # Check if user tries to sell more
        render json: {'error_message': I18n.t('errors.you_dont_have_enough_of_this')}, status: 400 and return if (Item.find_by(loader: params[:loader], user: current_user, location: current_user.location).count rescue 0) < quantity
        
        # Destroy items
        Item.remove_from_user({loader: params[:loader], user: current_user, location: current_user.location, amount: quantity})
        
      elsif params[:type] == "ship" and params[:loader]
      
        # Check if user tries to sell more
        render json: {'error_message': I18n.t('errors.you_dont_have_enough_of_this_or_trying_to_sell_active_ship')}, status: 400 and return if Spaceship.where(user: current_user, location: current_user.location, name: params[:loader]).count < quantity
      
        ships = Spaceship.where(user: current_user, location: current_user.location, name: params[:loader]).limit(quantity) rescue nil
        
        if ships
          ships.each do |ship|
            # Check if active ship - Fallback
            render json: {'error_message': I18n.t('errors.you_cant_sell_active_ship')}, status: 400 and return if ship == current_user.active_spaceship
            
            ship.destroy
          end
        else
          render json: {}, status: 400 and return
        end
      else
        render json: {}, status: 400 and return
      end
      
      # Deduct Units
      current_user.give_units(price) unless player_market
      
      # Generate Listing
      fill_listing = MarketListing.where(loader: params[:loader], location: current_user.location).where("amount < 20").first rescue nil
      if fill_listing and !player_market
        fill_listing.update_columns(amount: fill_listing.amount + quantity)
      else
        rabat = (rand(1.0..1.2) * rand(0.98..1.02)) unless player_market
        if params[:type] == "item"
          if player_market
            MarketListing.create(loader: params[:loader], listing_type: 'item', location: current_user.location, price: price, amount: quantity, user: current_user)
          else
            MarketListing.create(loader: params[:loader], listing_type: 'item', location: current_user.location, price: (get_item_attribute(params[:loader], 'price') * rabat).round, amount: quantity)
          end
        elsif params[:type] == "ship"
          if player_market
            MarketListing.create(loader: params[:loader], listing_type: 'ship', location: current_user.location, price: price, amount: quantity, user: current_user)
          else
            MarketListing.create(loader: params[:loader], listing_type: 'ship', location: current_user.location, price: (Spaceship.ship_variables[params[:loader]]['price'] * rabat).round, amount: quantity)
          end
        end
      end
      
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def create_buy
    if params[:name] and params[:amount] and params[:price]
      name = params[:name]
      amount = params[:amount].to_i
      price = params[:price].to_i
      
      # Check Balance
      render json: {'error_message': I18n.t('errors.you_dont_have_enough_credits')}, status: 400 and return unless current_user.reload.units >= amount * price
      current_user.reduce_units(amount * price)
      
      # Find Loader
      if Spaceship.ship_variables.keys.include?(name)
        type = "ship"
      elsif get_item_attribute(name[/\(.*?\)/].gsub("(", "").gsub(")", ""), "name")
        type = "item"
        name = name[/\(.*?\)/].gsub("(", "").gsub(")", "")
      else
        render json: {'error_message': I18n.t('errors.name_not_found')}, status: 400 and return
      end
      
      MarketListing.create(loader: name, listing_type: type, location: current_user.location, price: price, amount: amount, user: current_user, order_type: :buy)
      
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def fulfill_buy
    if params[:id] and params[:amount]
      amount = params[:amount].to_i rescue nil
      listing = MarketListing.find(params[:id]) rescue nil
      if amount and listing and listing.location == current_user.location and amount >= 1
        # Check Amount
        render json: {'error_message': I18n.t('errors.you_dont_have_enough_of_this')}, status: 400 and return if (Item.find_by(loader: listing.loader, location: current_user.location, user: current_user).count rescue 0) < amount
        render json: {'error_message': I18n.t('errors.buyer_doesnt_want_that_much')}, status: 400 and return if amount > listing.amount
        # Remove Items and give credits
        Item.remove_from_user({loader: listing.loader, amount: amount, location: current_user.location, user: current_user})
        current_user.give_units(listing.price * amount * 0.95)
        # Give Items to Buyer and reduce listing
        Item.give_to_user({loader: listing.loader, amount: amount, location: current_user.location, user: listing.user})
        new_amount = listing.amount - amount
        listing.update_columns(amount: new_amount)
        listing.destroy if new_amount == 0
        # If listing belonged to user -> notify
        if listing.user
          if listing.item?
            ActionCable.server.broadcast("player_#{listing.user_id}", method: 'notify_info', text: I18n.t('notification.someone_sold', amount: amount, name: get_item_attribute(listing.loader, "name")))
          else
            ActionCable.server.broadcast("player_#{listing.user_id}", method: 'notify_info', text: I18n.t('notification.someone_sold', amount: amount, name: listing.loader))
          end
          ActionCable.server.broadcast("player_#{listing.user_id}", method: 'refresh_player_info')
        end
        render json: {new_amount: new_amount}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def my_listings
    listings = MarketListing.where(location: current_user.location).where(user: current_user)
    render partial: 'stations/market/my_listings', locals: {market_listings: listings} and return
  end
  
  def delete_listing
    if params[:id]
      listing = MarketListing.find(params[:id]) rescue nil
      
      if listing and listing.user == current_user and listing.location == current_user.location
        
        # Is listing is buy -> return money
        if listing.buy?
          current_user.give_units(listing.amount * listing.price)
        elsif listing.sell? && listing.item?
          Item.give_to_user({location: current_user.location, user: current_user, loader: listing.loader, amount: listing.amount})
        elsif listing.sell? && listing.ship?
          listing.amount.times do
            Spaceship.create(location: current_user.location, user: current_user, name: listing.loader, hp: Spaceship.ship_variables[listing.loader]['hp'])
          end
        end
        
        listing.destroy
        
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  private
  
  def generate_price(loader, type, quantity)
    if loader and type
      listings = MarketListing.where(loader: loader, location: current_user.location).count
      if quantity and quantity.to_i > 0
        if type == "item"
          
          price = (get_item_attribute(loader, 'price') rescue 0) * 0.9
          
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
          price = (Spaceship.ship_variables[loader]['price'] rescue 0) * 0.9
        end
        listings = 1 if listings == 0
        price = price * quantity.to_i if price
        price = (price rescue nil / (1.05 ** listings)).round rescue nil
        return price
      end
    end
  end
  
end