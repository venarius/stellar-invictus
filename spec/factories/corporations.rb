FactoryBot.define do
  factory :corporation do
    founder_id { 1 }
    name { "MyString" }
    ticker { "MyString" }
    tax { 1.5 }
  end
end
