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
    noise = Perlin::Noise.new 1, seed: Time.now.to_i
    Location.where(location_type: 'station').each_with_index do |location, index|
      rabat = noise[(index + 1.0) / 10.0] + 0.5
      ITEMS.each do |item|
        rand(0..1).times do
          rand(3..15).times do
            MarketListing.create(loader: item, location: location, listing_type: 'item', price: (get_item_attribute(item, 'price') * rabat * rand(0.95..1.05)).round, amount: rand(10..30))
          end
        end
      end
      SHIP_VARIABLES.each do |key, value|
        rand(0..10).times do
          MarketListing.create(loader: key, location: location, listing_type: 'ship', price: (value['price'] * rabat * rand(0.95..1.05)).round, amount: rand(1..3))
        end
      end
    end
  end
end