namespace :economy do
  
  desc "Redo the economy"
  task :redo => :environment do
    def get_item_attribute(loader, attribute)
      atty = loader.split(".")
      out = ITEM_VARIABLES[atty[0]]
      loader.count('.').times do |i|
        out = out[atty[i+1]]
      end
      out[attribute] rescue nil
    end
      
    MarketListing.destroy_all
    noise = Perlin::Noise.new 1, seed: 1000
    noise_level = [0, 1, 2, 3, 4, 5, 6, 7, 8 , 9, 8, 7, 6, 5, 4, 3, 2, 1]
    i = 0
    
    Location.where(location_type: 'station').each_with_index do |location, index|
      rabat = (noise[(noise_level[i] + 1.0) / 10.0] + 1) - 0.5
      i = i + 1
      i = 0 if i >= noise_level.size
      
      ITEMS.each do |item|
        rand(0..1).times do
          rand(3..15).times do
            MarketListing.create(loader: item, location: location, listing_type: 'item', price: (get_item_attribute(item, 'price') * rabat * rand(0.95..1.05)).round, amount: rand(10..30))
          end
        end
      end
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
      
      # Customization
      if location.industrial_station?
        location.market_listings.where("loader ilike ?", "equipment.").each do |listing|
          listing.update_columns(price: (listing.price * rand(0.8..0.9)).round, amount: listing.amount * 2)
        end
      end
      
      if location.warfare_plant?
        location.market_listings.where("loader ilike ?", "equipment.weapons").each do |listing|
          listing.update_columns(price: (listing.price * rand(0.8..0.9)).round, amount: listing.amount * 2)
        end
      end
      
      if location.mining_station?
        location.market_listings.where("loader ilike ?", "asteroid.").each do |listing|
          listing.update_columns(price: (listing.price * rand(0.8..0.9)).round, amount: listing.amount * 2)
        end
      end
      
    end
  end
end