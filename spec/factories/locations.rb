FactoryBot.define do
  factory :location do
    name { Faker::Name.first_name }
    system { FactoryBot.create(:system) }
    location_type { 1 }
  end
end
