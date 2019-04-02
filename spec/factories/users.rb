FactoryBot.define do

  factory :user do
    pass = Faker::Internet.password(6)

    email { Faker::Internet.email }
    password { pass }
    password_confirmation { pass }
    name { "#{Faker::Name.first_name}AA" }
    family_name { "#{Faker::Name.first_name}AA" }
    avatar { "M_1" }
    confirmed_at { Date.today }
    docked { false }
    online { 1 }

    factory :user_with_location do
      system { System.first }
      location { system.locations.first }
      active_spaceship { create(:spaceship) }

      factory :user_with_faction do
        faction { Faction.first }
      end
    end

    factory :user_without_spaceship do
      faction { Faction.first }
      system { System.first }
      location { system.locations.first }
    end
  end

  factory :faction do
    name { Faker::Fallout.faction }
    description { Faker::Lorem.sentences }
  end

end
