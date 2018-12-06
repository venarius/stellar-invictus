class MarketListing < ApplicationRecord
  belongs_to :location
  
  enum listing_type: [:item, :ship]
end
