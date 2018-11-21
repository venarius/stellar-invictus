class Fleet < ApplicationRecord
  belongs_to :chat_room
  belongs_to :creator, class_name: 'User', foreign_key: 'user_id'
  has_many :users
end
