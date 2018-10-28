FactoryBot.define do
  factory :mail do
    sender_id { FactoryBot.create(:user) }
    recipient_id { FactoryBot.create(:user) }
    header { "MyString" }
    body { "MyText" }
    units { 0 }
  end
end
