def get_item_attribute(loader, attribute)
  atty = loader.split(".")
  out = ITEM_VARIABLES[atty[0]]
  loader.count('.').times do |i|
    out = out[atty[i+1]]
  end
  out[attribute] rescue nil
end

noise = Perlin::Noise.new 1, seed: Time.now.to_i
Location.where(location_type: 'station').sort(Arel.sql("RANDOM()")).limit((Location.all.count / 3).round).each_with_index do |location, index|
  rabat = noise[(index + 1.0) / 10.0] + 0.5
  MarketListing.where(location: location).each do |ml|
    # Update Prices
    if ml.listing_type == "item"
      ml.update_columns(price: (get_item_attribute(ml.loader, 'price') * rabat * rand(0.95..1.05)).round)
    else
      ml.update_columns(price: (SHIP_VARIABLES[ml.loader]['price'] * rabat * rand(0.95..1.05)).round)
    end
    
    # Restock
    while ml.reload.amount < rand(5..10)
      ml.update_columns(amount: ml.amount + rand(3..5))
    end
  end
  
  # Add new Listings
  if MarketListing.where(location: location, listing_type: 'ship').count < 10
    SHIP_VARIABLES.each do |key, value|
      if !value['faction']
        rand(0..10).times do
          MarketListing.create(loader: key, location: location, listing_type: 'ship', price: (value['price'] * rabat * rand(0.95..1.05)).round, amount: rand(1..3))
        end
      elsif location.faction_id and value['faction'] == location.faction_id
        rand(0..10).times do
          MarketListing.create(loader: key, location: location, listing_type: 'ship', price: (value['price'] * rabat * rand(0.95..1.05)).round, amount: rand(1..3))
        end
      end
    end
  end
  
  if MarketListing.where(location: location, listing_type: 'item').count < rand(45..65)
    ITEMS.each do |item|
      rand(0..1).times do
        rand(3..6).times do
          MarketListing.create(loader: item, location: location, listing_type: 'item', price: (get_item_attribute(item, 'price') * rabat * rand(0.95..1.05)).round, amount: rand(10..30))
        end
      end
    end
  else
    MarketListing.where(location: location, listing_type: 'item').limit((MarketListing.where(location: location, listing_type: 'item').count / rand(3..5)).round).delete_all
  end
end