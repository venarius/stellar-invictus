FactoryBot.define do
  factory :system do
    name { Faker::Space.galaxy }
    
    factory :high_sec_system do
      security_status { 0 }
    end
    
    factory :mid_sec_system do
      security_status { 1 }
    end
    
    factory :low_sec_system do
      security_status { 2 }
    end
  end
end
