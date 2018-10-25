require 'rails_helper'

describe System do
  context 'new system' do
    describe 'attributes' do
      it { should respond_to :name }
      it { should respond_to :users }
      it { should respond_to :security_status }
      it { should respond_to :destinations }
      it { should respond_to :jumpgates }
      it { should respond_to :chat_messages }
    end
   
    describe 'Relations' do
      it { should have_many :users }
      it { should have_many :jumpgates }
      it { should have_many :destinations }
      it { should have_many :chat_messages }
    end
    
    describe 'Enums' do
       it { should define_enum_for(:security_status).with([:high, :mid, :low]) } 
    end
  end
end
