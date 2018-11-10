require 'rails_helper'

describe Npc do
  context 'new npc' do
    describe 'attributes' do
      it { should respond_to :location }
      it { should respond_to :npc_type }
      it { should respond_to :target }
    end
   
    describe 'Relations' do
      it { should belong_to :location }
    end
    
    describe 'Enums' do
       it { should define_enum_for(:npc_type).with([:enemy, :police]) } 
    end
  end
end