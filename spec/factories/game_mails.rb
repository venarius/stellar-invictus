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

FactoryBot.define do
  factory :game_mail do
    sender_id { create(:user) }
    recipient_id { create(:user) }
    header { 'MyString' }
    body { 'MyText' }
    units { 0 }
  end
end
