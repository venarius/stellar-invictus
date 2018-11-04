require 'rails_helper'

describe Spaceship do
  context 'new spaceship' do
    describe 'attributes' do
      it { should respond_to :user }
      it { should respond_to :name }
    end
   
    describe 'Relations' do
      it { should belong_to :user }
    end
  end
end
