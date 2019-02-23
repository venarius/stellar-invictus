FactoryBot.define do
  factory :structure do
    structure_type { 0 }
    location { Location.first }
    user { nil }
    
    factory :monument do
      structure_type { :monument }
      location { Location.first }
    end
    
  end
end
