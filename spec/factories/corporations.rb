FactoryBot.define do
  factory :corporation do
    name { "MyString" }
    ticker { "XXX" }
    tax { 1.5 }
    bio { "Blub" }
    chat_room { FactoryBot.create(:chat_room, chatroom_type: :corporation) }
  end
end
