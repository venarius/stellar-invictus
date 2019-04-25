# == Schema Information
#
# Table name: finance_histories
#
#  id             :bigint(8)        not null, primary key
#  action         :integer
#  amount         :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  corporation_id :bigint(8)
#  user_id        :bigint(8)
#
# Indexes
#
#  index_finance_histories_on_corporation_id  (corporation_id)
#  index_finance_histories_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#  fk_rails_...  (user_id => users.id)
#

class FinanceHistory < ApplicationRecord
  belongs_to :user
  belongs_to :corporation

  enum action: [:deposit, :withdraw]
end
