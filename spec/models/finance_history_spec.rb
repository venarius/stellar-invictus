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
      it { should define_enum_for(:action).with([:deposit, :withdraw]) }
    end
  end
end
