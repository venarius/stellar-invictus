FactoryBot.define do
  factory :item do
    user { nil }
    location { nil }
    spaceship { nil }
    loader { "test" }
  end
end
