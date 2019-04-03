# == Schema Information
#
# Table name: fleets
#
#  id           :bigint(8)        not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chat_room_id :bigint(8)
#  user_id      :bigint(8)
#
# Indexes
#
#  index_fleets_on_chat_room_id  (chat_room_id)
#  index_fleets_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (chat_room_id => chat_rooms.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :fleet do
    chat_room { create(:chat_room) }
    creator { nil }
  end
end
