require 'rails_helper'

describe ChatMessage do
  context 'new chat message' do
    describe 'attributes' do
      it { should respond_to :user }
      it { should respond_to :body }
    end
   
    describe 'Relations' do
      it { should belong_to :user }
    end
    
    describe 'Validations' do
      describe 'body' do
        it { should validate_presence_of :body }
        it { should validate_length_of :body }
        it { should allow_values('Hello there').for :body }
        it { should_not allow_values('', nil).for :body }
      end
    end
  end
end
