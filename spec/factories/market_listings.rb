FactoryBot.define do
  factory :market_listing do
    loader { "MyString" }
    listing_type { 1 }
    price { 1 }
    location { nil }
  end
end
