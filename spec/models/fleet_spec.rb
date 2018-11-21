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
  end
end
