require 'rails_helper'

describe ChatRoom do
  context 'new chat room' do
    describe 'attributes' do
      it { should respond_to :users }
      it { should respond_to :title }
      it { should respond_to :chat_messages }
      it { should respond_to :location }
    end
   
    describe 'Relations' do
      it { should belong_to :location }
      it { should have_and_belong_to_many :users }
      it { should have_many :chat_messages }
    end
    
    describe 'Validations' do
      describe 'title' do
        it { should validate_presence_of :title }
        it { should validate_length_of :title }
        it { should allow_values('Hello there').for :title }
        it { should_not allow_values('', nil, 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA').for :title }
      end
    end
    
    describe 'Enums' do
       it { should define_enum_for(:chatroom_type).with([:global, :local, :custom]) } 
    end
    
    describe 'Functions' do
      describe 'update_local_players' do
        it 'should send actioncable' do
          room = FactoryBot.create(:chat_room)
          room.update_local_players
        end
      end
    end
  end
end
