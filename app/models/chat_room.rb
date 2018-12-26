class ChatRoom < ApplicationRecord
  belongs_to :location, optional: true
  has_and_belongs_to_many :users
  has_many :chat_messages, dependent: :destroy
  has_one :fleet, dependent: :destroy
  
  validates :title, presence: true, length: { maximum: 20, too_long: I18n.t('validations.too_long_chat_room') }
  
  enum chatroom_type: [:global, :local, :custom, :corporation]
  
  # Before Create -> Generate Identifier
  before_create do
    self.identifier = generate_random_identifier unless self.identifier and self.identifier != ""
  end
  
  # Update local players
  def update_local_players
    ChatChannel.broadcast_to(self, method: 'update_players', names: ApplicationController.helpers.map_and_sort(self.users.where("online > 0")), fleet: self.fleet.present?)
  end
  
  private
  
  # Generate random Identifier for ChatRoom
  def generate_random_identifier
    identifier = (0...8).map { (65 + rand(26)).chr }.join.upcase
    if ChatRoom.where(identifier: identifier).empty?
      identifier
    else
      generate_random_identifier
    end
  end
end
