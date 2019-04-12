# == Schema Information
#
# Table name: market_listings
#
#  id           :bigint(8)        not null, primary key
#  amount       :integer
#  listing_type :integer
#  loader       :string
#  order_type   :integer          default("sell")
#  price        :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  location_id  :bigint(8)
#  user_id      :bigint(8)
#
# Indexes
#
#  index_market_listings_on_listing_type  (listing_type)
#  index_market_listings_on_location_id   (location_id)
#  index_market_listings_on_order_type    (order_type)
#  index_market_listings_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :market_listing do
    loader { 'MyString' }
    listing_type { 1 }
    price { 1 }
    location { nil }
  end
end
