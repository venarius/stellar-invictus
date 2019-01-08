FactoryBot.define do
  factory :poll do
    status { 1 }
    question { "MyString" }
    working_on { false }
  end
end
