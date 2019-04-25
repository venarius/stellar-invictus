# == Schema Information
#
# Table name: chat_rooms
#
#  id            :bigint(8)        not null, primary key
#  chatroom_type :integer
#  identifier    :string
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  location_id   :bigint(8)
#  system_id     :bigint(8)
#
# Indexes
#
#  index_chat_rooms_on_chatroom_type  (chatroom_type)
#  index_chat_rooms_on_identifier     (identifier) UNIQUE
#  index_chat_rooms_on_location_id    (location_id)
#  index_chat_rooms_on_system_id      (system_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (system_id => systems.id)
#

class ChatRoom < ApplicationRecord
  ensure_by :identifier, :id

  ## -- RELATIONSHIPS
  belongs_to :location, optional: true
  has_and_belongs_to_many :users
  has_many :chat_messages, dependent: :destroy
  has_one :fleet, dependent: :destroy
  belongs_to :system, optional: true

  ## -- VALIDATIONS
  validates :title, presence: true, length: { maximum: 20, too_long: I18n.t('validations.too_long_chat_room') }
  validates :identifier, presence: true, uniqueness: true

  ## -- ATTRIBUTES
  enum chatroom_type: [:global, :local, :custom, :corporation]

  ## -- CALLBACKS
  before_validation :set_identifier

  ## — CLASS METHODS
  def self.global
    @global ||= ChatRoom.where(chatroom_type: :global).first
  end

  ## — INSTANCE METHODS
  def user_in_room?(user)
    self.users.where(id: user.id).exists?
  end

  def update_local_players
    if self.fleet.present?
      color = self.users.is_online.in_name_order.map { |p| p.active_spaceship.get_hp_color }
    end

    ChatChannel.broadcast_to(self,
      method: 'update_players',
      names: ApplicationController.helpers.map_and_sort(self.users.is_online),
      fleet: self.fleet.present?,
      color: color
    )
  end

  def channel_id
    "channel-#{self.identifier}"
  end

  private
  def set_identifier
    self.identifier ||= SecureRandom.uuid
  end
end
