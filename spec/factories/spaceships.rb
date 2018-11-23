FactoryBot.define do
  factory :spaceship do
    user { FactoryBot.create(:user_without_spaceship) }
    name { "Nano" }
    hp { 50 }
  end
end
