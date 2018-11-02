FactoryBot.define do
  factory :spaceship do
    user { nil }
    name { "MyString" }
    image { "MyString" }
    hp { 1 }
    armor { 1 }
    power { 1 }
    defense { 1 }
    price { 1 }
  end
end
