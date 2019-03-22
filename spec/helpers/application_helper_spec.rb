require 'rails_helper'

describe ApplicationHelper do
  describe 'navbar_item' do
    it 'should return html for navbar' do
      allow(self).to receive('current_page?').and_return("/")
      expect(navbar_item(root_path, 'navbar.home')).to include("Home")
    end
  end

  describe 'online_status' do
    it 'should return online now if user is online' do
      user = FactoryBot.create(:user_with_faction, online: 1)
      expect(online_status(user)).to eq("<i class='fa fa-circle fa-xs color-green'></i>&nbsp;&nbsp;Online Now")
    end
    it 'should return online ago if user is not online' do
      user = FactoryBot.create(:user_with_faction, last_action: DateTime.now, online: 0)
      expect(online_status(user)).to include("ago")
    end
  end

  describe 'get_item_attribute' do
    it 'should return attribute of item' do
      expect(get_item_attribute('test', 'weight')).to eq(1)
    end

    it 'should return nil attribute of item' do
      expect(get_item_attribute('hudaf', 'weight')).to eq(nil)
    end
  end
end
