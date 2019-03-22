class Fleet < ApplicationRecord
  belongs_to :chat_room, dependent: :destroy
  belongs_to :creator, class_name: 'User', foreign_key: 'user_id'
  has_many :users

  before_destroy do
    self.users.each do |user|
      user.update_columns(fleet_id: nil)
      ActionCable.server.broadcast("player_#{user.id}", method: 'reload_fleet')
    end
  end
end
