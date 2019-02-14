def get_item_attribute(loader, attribute)
  atty = loader.split(".")
  out = ITEM_VARIABLES[atty[0]]
  loader.count('.').times do |i|
    out = out[atty[i+1]]
  end
  out[attribute] rescue nil
end

noise = Perlin::Noise.new 1, seed: 1000
noise_level = [0, 1, 2, 3, 4, 5, 6, 7, 8 , 9, 8, 7, 6, 5, 4, 3, 2, 1]
i = 0

Location.where(location_type: 'station', player_market: false).order(Arel.sql("RANDOM()")).limit((Location.all.count / 3).round).each_with_index do |location, index|
  rabat = ((noise[(noise_level[i] + 1.0) / 10.0] + 1) - 0.5).clamp(0.98, 1.02)
  i = i + 1
  i = 0 if i >= noise_level.size
    
  MarketListing.where(location: location).each do |ml|
    # Restock
    while ml.reload.amount < rand(5..10)
      ml.update_columns(amount: ml.amount + rand(3..5))
    end
    
    # Customization
    if location.industrial_station?
      location.market_listings.where("loader ilike ?", "equipment.").each do |listing|
        listing.update_columns(price: (listing.price * rand(0.96..0.98)).round, amount: listing.amount * 2)
      end
    end
    
    if location.warfare_plant?
      location.market_listings.where("loader ilike ?", "equipment.weapons").each do |listing|
        listing.update_columns(price: (listing.price * rand(0.96..0.98)).round, amount: listing.amount * 2)
      end
    end
    
    if location.mining_station?
      location.market_listings.where("loader ilike ?", "asteroid.").each do |listing|
        listing.update_columns(price: (listing.price * rand(0.96..0.98)).round, amount: listing.amount * 2)
      end
    end
  end
  
  # Add new Listings
  if MarketListing.where(location: location, listing_type: 'ship').count < 10
    SHIP_VARIABLES.each do |key, value|
      if !value['faction']
        rand(0..10).times do
          MarketListing.create(loader: key, location: location, listing_type: 'ship', price: (value['price'] * rabat * rand(0.98..1.02)).round, amount: rand(1..3))
        end
      elsif location.faction_id and value['faction'] == location.faction_id
        rand(0..10).times do
          MarketListing.create(loader: key, location: location, listing_type: 'ship', price: (value['price'] * rabat * rand(0.98..1.02)).round, amount: rand(1..3))
        end
      end
    end
  end
  
  if MarketListing.where(location: location, listing_type: 'item').count < rand(45..65)
    (EQUIPMENT_EASY + EQUIPMENT_MEDIUM).each do |item|
      next if item == "asteroid.lunarium_ore"
      rand(0..1).times do
        rand(3..6).times do
          MarketListing.create(loader: item, location: location, listing_type: 'item', price: (get_item_attribute(item, 'price') * rabat * rand(0.98..1.02)).round, amount: rand(10..30))
        end
      end
    end
  else
    MarketListing.where(location: location, listing_type: 'item').limit((MarketListing.where(location: location, listing_type: 'item').count / rand(3..5)).round).delete_all
  end
  
  # Combine MarketListings with same price
  location.market_listings.each do |ml|
    listings =  MarketListing.where(location: location, price: ml.price, loader: ml.loader).where.not(id: ml.id)
    if listings.present?
      listings.first.update_columns(amount: listings.first.amount + ml.amount)
      ml.destroy and next
    end
  end
end