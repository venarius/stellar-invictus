require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def after_sign_in_path_for(resource)
        super resource
    end
    def call_police(user)
        super user
    end
    def update_last_action
        super
    end
  end

  before (:each) do
    @user = FactoryBot.create(:user)
    sign_in @user
  end

  describe 'After sign in' do
    it 'redirects to the /factions page if not faction' do
      expect(controller.after_sign_in_path_for(@user)).to eq(factions_path)
    end
    it 'redirects to the / page if faction' do
      @user.faction = Faction.first
      @user.save(validate: false)
      expect(controller.after_sign_in_path_for(@user)).to eq(game_path)
    end
  end
  
  describe 'Call Police' do
    it 'should call police on user in highsec' do
      system = System.where(security_status: 'high').first
      @user = FactoryBot.create(:user_with_faction, system: system, location: system.locations.first)
      controller.call_police(@user)
      expect(PoliceWorker.jobs.size).to eq(1)
    end
    it 'should call police on user in midsec' do
      system = System.where(security_status: 'medium').first
      @user = FactoryBot.create(:user_with_faction, system: system, location: system.locations.first)
      controller.call_police(@user)
      expect(PoliceWorker.jobs.size).to eq(1)
    end
    it 'shouldnt call police on user in lowsec' do
      system = System.where(security_status: 'low').first
      @user = FactoryBot.create(:user_with_faction, system: system, location: system.locations.first)
      controller.call_police(@user)
      expect(PoliceWorker.jobs.size).to eq(0)
    end
  end
  
  describe 'update_last_action' do
    it 'should update last_action of user' do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
      controller.update_last_action
      expect(@user.reload.last_action).to be_present
    end
  end
end