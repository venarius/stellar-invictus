class ChatRoom < ApplicationRecord
  belongs_to :location, optional: true
  has_and_belongs_to_many :users
  has_many :chat_messages, dependent: :destroy
  has_one :fleet, dependent: :destroy
  
  enum chatroom_type: [:global, :local, :custom]
  
  validates :title, presence: true, length: { maximum: 20, too_long: I18n.t('validations.too_long_chat_room') }
end
