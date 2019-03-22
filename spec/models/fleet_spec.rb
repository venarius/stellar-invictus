require 'rails_helper'

describe Fleet do
  context 'new fleet' do
    describe 'attributes' do
      it { should respond_to :creator }
      it { should respond_to :users }
      it { should respond_to :chat_room }
    end

    describe 'Relations' do
      it { should belong_to :chat_room }
      it { should belong_to :creator }
      it { should have_many :users }
    end

    describe 'Functions' do
      describe 'before_destroy' do
        it 'should remove all active users from fleet' do
          user = FactoryBot.create(:user_with_faction)
          fleet = FactoryBot.create(:fleet, creator: user)
          fleet.users << user
          fleet.destroy
          expect(user.reload.fleet).to eq(nil)
        end
      end
    end
  end
end
