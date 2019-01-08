FactoryBot.define do
  factory :poll do
    status { 1 }
    question { "MyString" }
    forum_link { "https://forums.stellar-invictus.com" }
  end
end
