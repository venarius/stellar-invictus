FactoryBot.define do

  factory :user do
    pass = Faker::Internet.password(6)

      email { Faker::Internet.email }
      password { pass }
      password_confirmation { pass }
      name { Faker::Name.first_name + "AA" }
      avatar { "M_1" }
      family_name { Faker::Name.first_name + "AA" }
      confirmed_at { Date.today }
      docked { false }
      online { 1 }

      factory :user_with_faction do
        faction { Faction.first }
        system { System.first }
        location { Location.first }
        active_spaceship_id { FactoryBot.create(:spaceship).id }
      end

      factory :user_without_spaceship do
        faction { Faction.first }
        system { System.first }
        location { Location.first }
      end
  end

    factory :faction do
      name { Faker::Fallout.faction }
        description { Faker::Lorem.sentences }
    end

end
