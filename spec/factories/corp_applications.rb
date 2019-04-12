# == Schema Information
#
# Table name: corp_applications
#
#  id               :bigint(8)        not null, primary key
#  application_text :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  corporation_id   :bigint(8)
#  user_id          :bigint(8)
#
# Indexes
#
#  index_corp_applications_on_corporation_id  (corporation_id)
#  index_corp_applications_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :corp_application do
    user { nil }
    corporation { nil }
    application_text { 'MyText' }
  end
end
