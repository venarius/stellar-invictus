class MarketListing < ApplicationRecord
  belongs_to :location
  
  enum listing_type: [:item, :ship]
  
  def is_asteroid
    self.loader.starts_with?('asteroid.')
  end
end
