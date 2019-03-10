class AddOrderTypeToMarketListings < ActiveRecord::Migration[5.2]
  def change
    add_column :market_listings, :order_type, :integer, default: 0
  end
end
