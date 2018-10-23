require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def after_sign_in_path_for(resource)
        super resource
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
end