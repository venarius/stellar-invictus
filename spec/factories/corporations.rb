# == Schema Information
#
# Table name: corporations
#
#  id           :bigint(8)        not null, primary key
#  bio          :text
#  motd         :text
#  name         :string
#  tax          :float            default(0.0)
#  ticker       :string
#  units        :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chat_room_id :bigint(8)
#
# Indexes
#
#  index_corporations_on_chat_room_id  (chat_room_id)
#  index_corporations_on_name          (name) UNIQUE
#  index_corporations_on_ticker        (ticker) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (chat_room_id => chat_rooms.id)
#

FactoryBot.define do
  factory :corporation do
    name { RandService.upcase_alpha(8) }
    ticker { RandService.upcase_alpha(3) }
    tax { (rand() * 50).round(1) }
    bio { 'Blub' }
    chat_room { create(:chat_room, chatroom_type: :corporation) }
  end
end
