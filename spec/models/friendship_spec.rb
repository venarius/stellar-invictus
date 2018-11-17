require 'rails_helper'

describe Friendship do
  context 'new friendship' do
    describe 'attributes' do
      it { should respond_to :user }
      it { should respond_to :friend }
    end
   
    describe 'Relations' do
      it { should belong_to :user }
      it { should belong_to :friend }
    end
  end
end
