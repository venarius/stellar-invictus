# == Schema Information
#
# Table name: chat_rooms
#
#  id            :bigint(8)        not null, primary key
#  chatroom_type :integer
#  identifier    :string
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  location_id   :bigint(8)
#  system_id     :bigint(8)
#
# Indexes
#
#  index_chat_rooms_on_chatroom_type  (chatroom_type)
#  index_chat_rooms_on_identifier     (identifier) UNIQUE
#  index_chat_rooms_on_location_id    (location_id)
#  index_chat_rooms_on_system_id      (system_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (system_id => systems.id)
#

FactoryBot.define do
  factory :chat_room do
    title { SecureRandom.hex(rand(5..10)) }
    chatroom_type { :custom }
  end
end
