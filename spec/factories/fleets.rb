FactoryBot.define do
  factory :fleet do
    chat_room { FactoryBot.create(:chat_room) }
    creator { nil }
  end
end
