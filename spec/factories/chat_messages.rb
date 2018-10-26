FactoryBot.define do
  factory :chat_message do
    user { user }
    system { system }
    type { rand(1) }
    body { Faker::Lorem.sentences }
  end
end
