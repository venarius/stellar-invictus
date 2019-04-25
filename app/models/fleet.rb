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

class Fleet < ApplicationRecord
  belongs_to :chat_room, dependent: :destroy
  belongs_to :creator, class_name: User.name, foreign_key: :user_id
  has_many :users

  before_destroy do
    self.users.each do |user|
      user.update(fleet_id: nil)
      user.broadcast(:reload_fleet)
    end
  end
end
