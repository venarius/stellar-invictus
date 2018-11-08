FactoryBot.define do
  factory :item do
    user { nil }
    location { nil }
    spaceship { nil }
    load { "MyString" }
  end
end
