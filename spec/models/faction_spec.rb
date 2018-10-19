require 'rails_helper'

describe Faction do
    context 'new faction' do
        describe 'attributes' do
            it { should respond_to :name }
            it { should respond_to :description }
            it { should respond_to :users }
        end
       
        describe 'Relations' do
            it { should have_many :users }
        end
    end
end