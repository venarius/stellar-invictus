# == Schema Information
#
# Table name: chat_messages
#
#  id           :bigint(8)        not null, primary key
#  body         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chat_room_id :bigint(8)
#  user_id      :bigint(8)
#
# Indexes
#
#  index_chat_messages_on_chat_room_id  (chat_room_id)
#  index_chat_messages_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (chat_room_id => chat_rooms.id)
#  fk_rails_...  (user_id => users.id)
#

class ChatMessage < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room

  validates :body, presence: true, length: { maximum: 300, too_long: I18n.t('validations.too_long_chat_message') }

  after_create_commit { ChatMessageBroadcastJob.perform_now self }
end
