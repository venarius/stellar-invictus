class MarketController < ApplicationController
  before_action :check_docked

  include ApplicationHelper

  def list
    if params[:loader]
      listings = MarketListing.where(location: current_user.location).where("loader ilike ?", "%#{params[:loader]}%")
      render(partial: 'stations/market/list', locals: { market_listings: listings, can_create_buy_order: current_user.location.player_market }) && (return)
    end
    render json: {}, status: :bad_request
  end

  def search
    if params[:search]

      listings = MarketListing.where(location: current_user.location).where("loader ilike ?", "%#{params[:search].gsub(' ', '_')}%")
      render(partial: 'stations/market/list', locals: { market_listings: listings, can_create_buy_order: false }) && (return)
    end
    render json: {}, status: :bad_request
  end

  def buy
    if params[:id] && params[:amount]
      amount = params[:amount].to_i
      listing = MarketListing.ensure(params[:id])
      if listing && (listing.location == current_user.location) && (amount >= 1)

        # Check Amount
        render(json: { 'error_message': I18n.t('errors.you_cant_buy_that_much') }, status: :bad_request) && (return) if amount > listing.amount

        # Check Balance
        render(json: { 'error_message': I18n.t('errors.you_dont_have_enough_credits') }, status: :bad_request) && (return) unless current_user.reload.units >= listing.price * amount

        # If listing is item -> else..
        if listing.item?
          Item::GiveToUser.(location: current_user.location, user: current_user, loader: listing.loader, amount: amount)
        else
          # Check if met requirements
          ship = Spaceship.get_attributes(listing.loader)
          if ship['faction'] && ship['reputation_requirement']
            rank = Faction.find(ship['faction']).get_rank(current_user)
            render(json: { 'error_message': I18n.t('errors.you_dont_have_the_required_reputation') }, status: :bad_request) && (return) unless rank && (rank['type'] >= ship['reputation_requirement'])
          end

          amount.times do
            Spaceship.create(
              location: current_user.location,
              user: current_user,
              name: listing.loader,
              hp: Spaceship.get_attribute(listing.loader, :hp)
            )
          end
        end

        # Deduct units
        current_user.reduce_units(listing.price * amount)

        # If listing belonged to user -> give 95% of price to user and inform
        if listing.user
          listing.user.give_units(listing.price * amount * 0.95)
          listing.user.broadcast(:notify_info,
            text: I18n.t('notification.someone_bought', amount: amount, name: listing.name)
          )
          listing.user.broadcast(:refresh_player_info)
        end

        # Destroy Listing
        new_amount = listing.amount - amount
        listing.update(amount: new_amount)
        listing.destroy if new_amount == 0

        render(json: { 'new_amount': new_amount }, status: :ok) && (return)
      end
    end
    render json: {}, status: :bad_request
  end

  def appraisal
    price = generate_price(params[:loader], params[:type], params[:quantity])
    if price != nil
      render json: { "price": price }, status: :ok
    else
      render json: {}, status: :bad_request
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
        if Item.where(loader: params[:loader], user: current_user, location: current_user.location).count < quantity
          render(json: { 'error_message': I18n.t('errors.you_dont_have_enough_of_this') }, status: :bad_request) && (return)
        end

        # Destroy items
        Item::RemoveFromUser.(loader: params[:loader], user: current_user, location: current_user.location, amount: quantity)

      elsif (params[:type] == "ship") && params[:loader]

        # Check if user tries to sell more
        if Spaceship.where(user: current_user, location: current_user.location, name: params[:loader]).count < quantity
          render(json: { 'error_message': I18n.t('errors.you_dont_have_enough_of_this_or_trying_to_sell_active_ship') }, status: :bad_request) && (return)
        end
        ships = Spaceship.where(user: current_user, location: current_user.location, name: params[:loader]).limit(quantity)

        if ships
          ships.each do |ship|
            # Check if active ship - Fallback
            render(json: { 'error_message': I18n.t('errors.you_cant_sell_active_ship') }, status: :bad_request) && (return) if ship == current_user.active_spaceship

            ship.destroy
          end
        else
          render(json: {}, status: :bad_request) && (return)
        end
      else
        render(json: {}, status: :bad_request) && (return)
      end

      # Deduct Units
      current_user.give_units(price) unless player_market

      # Generate Listing
      fill_listing = MarketListing.where(loader: params[:loader], location: current_user.location).where("amount < 20").first
      if fill_listing && !player_market
        fill_listing.increment!(:amount, quantity)
      else

        attrs = {
          loader: params[:loader],
          location: current_user.location,
          amount: quantity,
          listing_type: params[:type]
        }

        if player_market
          attrs = attrs.merge(price: price, user: current_user)
        else
          rabat = (rand(1.0..1.2) * rand(0.98..1.02))
          info_class = (params[:type] == "item") ? Item : Spaceship
          attrs[:price] = (info_class.get_attribute(params[:loader], :price) * rabat).round
        end

        MarketListing.create(**attrs)
      end

      render(json: {}, status: :ok) && (return)
    end
    render json: {}, status: :bad_request
  end

  def create_buy
    if params[:name] && params[:amount] && params[:price]
      name = params[:name]
      amount = params[:amount].to_i
      price = params[:price].to_i

      # Check Balance
      render(json: { 'error_message': I18n.t('errors.you_dont_have_enough_credits') }, status: :bad_request) && (return) unless current_user.reload.units >= amount * price
      current_user.reduce_units(amount * price)

      # Find Loader
      if Spaceship.ship_variables.keys.include?(name)
        type = "ship"
      elsif Item.get_attribute(name[/\(.*?\)/].gsub("(", "").gsub(")", ""), :name)
        type = "item"
        name = name[/\(.*?\)/].gsub("(", "").gsub(")", "")
      else
        render(json: { 'error_message': I18n.t('errors.name_not_found') }, status: :bad_request) && (return)
      end

      MarketListing.create(loader: name, listing_type: type, location: current_user.location, price: price, amount: amount, user: current_user, order_type: :buy)

      render(json: {}, status: :ok) && (return)
    end
    render json: {}, status: :bad_request
  end

  def fulfill_buy
    if params[:id] && params[:amount]
      amount = params[:amount].to_i rescue nil
      listing = MarketListing.ensure(params[:id])
      if amount && listing && (listing.location == current_user.location) && (amount >= 1)
        # Check Amount
        render(json: { 'error_message': I18n.t('errors.you_dont_have_enough_of_this') }, status: :bad_request) && (return) if Item.where(loader: listing.loader, location: current_user.location, user: current_user).first.count < amount
        render(json: { 'error_message': I18n.t('errors.buyer_doesnt_want_that_much') }, status: :bad_request) && (return) if amount > listing.amount
        # Remove Items and give credits
        Item::RemoveFromUser.(loader: listing.loader, amount: amount, location: current_user.location, user: current_user)
        current_user.give_units(listing.price * amount * 0.95)
        # Give Items to Buyer and reduce listing
        Item::GiveToUser.(loader: listing.loader, amount: amount, location: current_user.location, user: listing.user)
        new_amount = listing.amount - amount
        listing.update(amount: new_amount)
        listing.destroy if new_amount == 0
        # If listing belonged to user -> notify
        if listing.user
          listing.user.broadcast(:notify_info,
            text: I18n.t('notification.someone_sold', amount: amount, name: listing.name)
          )
          listing.user.broadcast(:refresh_player_info)
        end
        render(json: { new_amount: new_amount }, status: :ok) && (return)
      end
    end
    render json: {}, status: :bad_request
  end

  def my_listings
    listings = MarketListing.where(location: current_user.location).where(user: current_user)
    render(partial: 'stations/market/my_listings', locals: { market_listings: listings }) && (return)
  end

  def delete_listing
    if params[:id]
      listing = MarketListing.ensure(params[:id])

      if listing && (listing.user == current_user) && (listing.location == current_user.location)

        # Is listing is buy -> return money
        if listing.buy?
          current_user.give_units(listing.amount * listing.price)
        elsif listing.sell? && listing.item?
          Item::GiveToUser.(location: current_user.location, user: current_user, loader: listing.loader, amount: listing.amount)
        elsif listing.sell? && listing.ship?
          listing.amount.times do
            Spaceship.create(location: current_user.location, user: current_user, name: listing.loader, hp: Spaceship.get_attribute(listing.loader, :hp))
          end
        end

        listing.destroy

        render(json: {}, status: :ok) && (return)
      end
    end
    render json: {}, status: :bad_request
  end

  private

  def generate_price(loader, type, quantity)
    if loader && type
      listings = MarketListing.where(loader: loader, location: current_user.location).count
      if quantity && (quantity.to_i > 0)
        if type == "item"

          price = Item.get_attribute(loader, :price, default: 0) * 0.9

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
          price = Spaceship.get_attribute(loader, :price, default: 0) * 0.9
        end
        listings = 1 if listings == 0
        price = price * quantity.to_i if price
        price = (price rescue nil / (1.05**listings)).round rescue nil
        return price
      end
    end
  end

end
