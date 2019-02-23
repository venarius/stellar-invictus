require 'rails_helper'

describe Mission do
  context 'new mission' do
    describe 'attributes' do
      it { should respond_to :location }
      it { should respond_to :mission_location }
      it { should respond_to :agent_name }
      it { should respond_to :agent_avatar }
      it { should respond_to :faction }
      it { should respond_to :text }
      it { should respond_to :reward }
      it { should respond_to :deliver_to }
      it { should respond_to :user }
      it { should respond_to :difficulty }
      it { should respond_to :mission_type }
      it { should respond_to :mission_status }
      it { should respond_to :enemy_amount }
      it { should respond_to :mission_loader }
      it { should respond_to :mission_amount }
      it { should respond_to :faction_bonus }
      it { should respond_to :faction_malus }
    end
    
    describe 'Relations' do
      it { should belong_to :faction }
      it { should belong_to :location }
      it { should belong_to :user }
      
      it { should have_one :mission_location }
    end
    
    describe 'Enums' do
       it { should define_enum_for(:mission_type).with([:tutorial, :delivery, :combat, :mining, :market, :vip]) } 
       it { should define_enum_for(:mission_status).with([:offered, :active, :failed, :completed]) } 
       it { should define_enum_for(:difficulty).with([:easy, :medium, :hard]) } 
    end
    
  end
end