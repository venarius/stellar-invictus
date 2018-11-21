class ChatRoom < ApplicationRecord
  belongs_to :location, optional: true
  has_and_belongs_to_many :users
  has_many :chat_messages, dependent: :destroy
  has_one :fleet, dependent: :destroy
  
  enum chatroom_type: [:global, :local, :custom]
  
  before_create do
    self.identifier = generate_random_identifier
  end
  
  validates :title, presence: true, length: { maximum: 20, too_long: I18n.t('validations.too_long_chat_room') }
  
  def generate_random_identifier
    identifier = (0...8).map { (65 + rand(26)).chr }.join.upcase
    if ChatRoom.where(identifier: identifier).empty?
      identifier
    else
      generate_random_identifier
    end
  end
end
