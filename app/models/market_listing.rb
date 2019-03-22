class MarketListing < ApplicationRecord
  belongs_to :location
  belongs_to :user, optional: true

  enum listing_type: [:item, :ship]
  enum order_type: [:sell, :buy]
end
