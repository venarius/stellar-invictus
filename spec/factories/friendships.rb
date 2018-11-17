FactoryBot.define do
  factory :friendship do
    user_id { 1 }
    friend_id { 1 }
    accepted { false }
  end
end
