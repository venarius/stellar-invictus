require 'rails_helper'

describe Faction do
    context 'new faction' do
        describe 'attributes' do
            it { should respond_to :name }
            it { should respond_to :description }
            it { should respond_to :users }
            it { should respond_to :location }
        end
       
        describe 'Relations' do
            it { should have_many :users }
            it { should have_one :location }
        end
    end
end