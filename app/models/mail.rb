class Mail < ApplicationRecord
  belongs_to :sender, :foreign_key => "sender_id", :class_name => "User"
  belongs_to :recipient, :foreign_key => "recipient_id", :class_name => "User"
  
  validates :body, presence: true
  validates :header, presence: true
  
  validates :body, length: { maximum: 500, too_long: I18n.t('validations.too_long_mail_body') }
  validates :header, length: { maximum: 100, too_long: I18n.t('validations.too_long_mail_header') }
  
  after_create do
    if units and units != 0 and units <= sender.units
      sender.update_columns(units: sender.units - units)
      recipient.update_columns(units: recipient.units + units)
    end
  end
end
