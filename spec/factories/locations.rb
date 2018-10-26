FactoryBot.define do
  factory :location do
    name { Faker::Name.first_name }
    system { FactoryBot.create(:system) }
    type { 1 }
  end
end
