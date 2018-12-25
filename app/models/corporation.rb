class Corporation < ApplicationRecord
  belongs_to :chat_room, dependent: :destroy
  has_many :users
  
  validates :name, :ticker, :tax, :bio, presence: true
  validates :name, uniqueness: true
  validates :ticker, uniqueness: true
  validates_format_of :name, :ticker, :with => /\A[a-zA-Z]+\z/i, message: I18n.t('validations.can_only_contain_letters')
  validates :name, length: { minimum: 4, maximum: 20,
            too_short: I18n.t('validations.too_short'), too_long: I18n.t('validations.too_long_name') }
  validates :ticker, length: { minimum: 3, maximum: 6,
            too_short: I18n.t('validations.too_short_3'), too_long: I18n.t('validations.too_long_ticker') }
  
  before_destroy do
    self.users.each do |user|
      user.update_columns(corporation_id: nil)
      ActionCable.server.broadcast("player_#{user.id}", method: 'reload_page')
    end
  end
end
