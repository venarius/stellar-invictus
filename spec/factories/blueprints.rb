FactoryBot.define do
  factory :blueprint do
    loader { "MyString" }
    chance { 1 }
  end
end
