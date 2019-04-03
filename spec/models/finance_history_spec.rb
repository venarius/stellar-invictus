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

require 'rails_helper'

describe FinanceHistory do
  context 'new finance_history' do
    describe 'attributes' do
      it { should respond_to :user }
      it { should respond_to :corporation }
      it { should respond_to :action }
    end

    describe 'Relations' do
      it { should belong_to :user }
      it { should belong_to :corporation }
    end

    describe 'Enums' do
      it { should define_enum_for(:action).with_values([:deposit, :withdraw]) }
    end
  end
end
