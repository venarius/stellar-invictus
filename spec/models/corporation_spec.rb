require 'rails_helper'

describe Corporation do
  context 'new corporation' do
    describe 'attributes' do
      it { should respond_to :motd }
      it { should respond_to :tax }
      it { should respond_to :bio }
      it { should respond_to :users }
      it { should respond_to :corp_applications }
      it { should respond_to :finance_histories }
      it { should respond_to :units }
      it { should respond_to :name }
      it { should respond_to :ticker }
    end
    
    describe 'Relations' do
      it { should have_many :users }
      it { should have_many :finance_histories }
      it { should have_many :corp_applications }
    end
  end
end