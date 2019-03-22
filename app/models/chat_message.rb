class ChatMessage < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room

  validates :body, presence: true, length: { maximum: 300, too_long: I18n.t('validations.too_long_chat_message') }

  after_create_commit { ChatMessageBroadcastJob.perform_now self }
end
