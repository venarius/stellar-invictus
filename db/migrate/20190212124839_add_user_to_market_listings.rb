class AddUserToMarketListings < ActiveRecord::Migration[5.2]
  def change
    add_reference :market_listings, :user, foreign_key: true
  end
end
