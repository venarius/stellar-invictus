# == Schema Information
#
# Table name: corporations
#
#  id           :bigint(8)        not null, primary key
#  bio          :text
#  motd         :text
#  name         :string
#  tax          :float            default(0.0)
#  ticker       :string
#  units        :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chat_room_id :bigint(8)
#
# Indexes
#
#  index_corporations_on_chat_room_id  (chat_room_id)
#  index_corporations_on_name          (name) UNIQUE
#  index_corporations_on_ticker        (ticker) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (chat_room_id => chat_rooms.id)
#

class Corporation < ApplicationRecord
  ## -- RELATIONSHIPS
  belongs_to :chat_room, dependent: :destroy, optional: true
  has_many :users
  has_many :finance_histories, dependent: :destroy
  has_many :corp_applications, dependent: :destroy

  ## -- VALIDATIONS
  validates :name,
    presence: true,
    uniqueness: true,
    format: { with: /\A[a-zA-Z]+\z/i, message: I18n.t('validations.can_only_contain_letters') },
    length: { minimum: 4, maximum: 20,
              too_short: I18n.t('validations.too_short'), too_long: I18n.t('validations.too_long_name') }

  validates :ticker,
    presence: true,
    uniqueness: true,
    format: { with: /\A[a-zA-Z]+\z/i, message: I18n.t('validations.can_only_contain_letters') },
    length: { minimum: 3, maximum: 6,
              too_short: I18n.t('validations.too_short_3'), too_long: I18n.t('validations.too_long_ticker') }

  validates :tax, presence: true, inclusion: { in: 0..100 }
  validates :bio, presence: true, length: { maximum: 1000, too_long: I18n.t('validations.too_long_game_mail') }, allow_blank: true
  validates :motd, length: { maximum: 1000, too_long: I18n.t('validations.too_long_game_mail') }

  ## -- CALLBACKS
  after_create :make_chat_room

  before_destroy do
    self.users.update_all(corporation_id: nil, corporation_role: :recruit)
    self.users.each do |user|
      user.broadcast(:reload_corporation)
    end
  end

  ## — INSTANCE METHODS
  def tax=(value)
    super([[value.to_f, 100].min, 0].max)
  end

  def is_member?(user)
    user.corporation_id == self.id
  end

  def is_founder?(user)
    is_member?(user) && user.founder?
  end

  ## ---- FIXME: Should use Pundit for this sort of permissions
  def user_can_edit?(user)
    is_member?(user) && %w[founder admiral commodore].include?(user.corporation_role)
  end
  alias can_see_applications? user_can_edit?
  alias can_reject_applications? user_can_edit?

  def can_update_motd?(user)
    is_member?(user) && %w[founder admiral commodore lieutenant].include?(user.corporation_role)
  end
  alias can_kick_users? can_update_motd?
  alias can_change_rank? can_update_motd?

  def can_deposit?(user)
    is_member?(user) && %w[founder admiral].include?(user.corporation_role)
  end
  alias can_withdraw? can_deposit?
  ## ----

  private

  def make_chat_room
    self.create_chat_room(title: 'Corporation', chatroom_type: :corporation)
    self.save!
  end
end
