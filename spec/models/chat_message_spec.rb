require 'rails_helper'

describe ChatMessage do
  context 'new chat message' do
    describe 'attributes' do
      it { should respond_to :user }
      it { should respond_to :system }
      it { should respond_to :body }
      it { should respond_to :type }
    end
   
    describe 'Relations' do
      it { should belong_to :user }
      it { should belong_to :system }
    end
    
    describe 'Validations' do
      describe 'body' do
        it { should validate_presence_of :body }
        it { should validate_length_of :body }
        it { should allow_values('Hello there').for :body }
        it { should_not allow_values('', nil).for :body }
      end
    end
    
    describe 'Enums' do
       it { should define_enum_for(:type).with([:local, :global]) } 
    end
  end
end
