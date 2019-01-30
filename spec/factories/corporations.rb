FactoryBot.define do
  factory :corporation do
    name { (0...8).map { (65 + rand(26)).chr }.join.upcase }
    ticker { (0...3).map { (65 + rand(26)).chr }.join.upcase }
    tax { 1.5 }
    bio { "Blub" }
    chat_room { FactoryBot.create(:chat_room, chatroom_type: :corporation) }
  end
end
