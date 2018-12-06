class CreateMarketListings < ActiveRecord::Migration[5.2]
  def change
    create_table :market_listings do |t|
      t.string :loader
      t.integer :listing_type
      t.integer :price
      t.integer :amount
      t.references :location, foreign_key: true

      t.timestamps
    end
  end
end
