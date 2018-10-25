class ChatMessage < ApplicationRecord
  belongs_to :user
  belongs_to :system, optional: true
  
  validates :body, presence: true, length: { maximum: 100, too_long: I18n.t('validations.too_long_chat_message') }
  
  enum type: [:local, :global]
end
