FactoryBot.define do
   
    factory :user do
        pass = Faker::Internet.password(6)
        
        email { Faker::Internet.email }
        password { pass }
        password_confirmation { pass }
        name { Faker::Name.first_name }
        avatar { "M_1.jpg" }
        family_name { Faker::Name.first_name }
        confirmed_at { Date.today }
        docked { false }
        
        factory :user_with_faction do
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