require 'rails_helper'

describe Spaceship do
  context 'new spaceship' do
    describe 'attributes' do
      it { should respond_to :user }
      it { should respond_to :hp }
      it { should respond_to :armor }
      it { should respond_to :power }
      it { should respond_to :defense }
      it { should respond_to :name }
      it { should respond_to :image }
      it { should respond_to :price }
    end
   
    describe 'Relations' do
      it { should belong_to :user }
    end
  end
end
