# == Schema Information
#
# Table name: game_mails
#
#  id           :bigint(8)        not null, primary key
#  body         :text
#  header       :string
#  read         :boolean          default(FALSE)
#  units        :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  recipient_id :integer
#  sender_id    :integer
#
# Indexes
#
#  index_game_mails_on_recipient_id  (recipient_id)
#  index_game_mails_on_sender_id     (sender_id)
#

class GameMail < ApplicationRecord
  paginates_per 10

  ## -- RELATIONSHIPS
  belongs_to :sender, foreign_key: :sender_id, class_name: User.name
  belongs_to :recipient, foreign_key: :recipient_id, class_name: User.name

  ## -- VALIDATIONS
  validates :body, presence: true
  validates :header, presence: true

  validates :body, length: { maximum: 500, too_long: I18n.t('validations.too_long_mail_body') }
  validates :header, length: { maximum: 100, too_long: I18n.t('validations.too_long_mail_header') }

  ## -- CALLBACKS
  after_create_commit :transfer_units, :start_worker

  private

  def transfer_units
    if (self&.units.to_i > 0) && (self.units <= sender.units)
      ActiveRecord::Base.transaction do
        sender.reduce_units(self.units)
        recipient.give_units(self.units)
      end
    end
  end

  def start_worker
    GameMailWorker.perform_async(self.recipient.id)
  end
end
