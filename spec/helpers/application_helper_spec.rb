require 'rails_helper'

describe ApplicationHelper do
  describe 'navbar_item' do
    it 'should return html for navbar' do
      allow(self).to receive('current_page?').and_return('/')
      expect(navbar_item(root_path, 'navbar.home')).to include('Home')
    end
  end

  describe 'online_status' do
    it 'should return online now if user is online' do
      user = create(:user_with_faction, online: 1)
      expect(online_status(user)).to eq("<i class='fa fa-circle fa-xs color-green'></i>&nbsp;&nbsp;Online Now")
    end
    it 'should return online ago if user is not online' do
      user = create(:user_with_faction, last_action: DateTime.now, online: 0)
      expect(online_status(user)).to include('ago')
    end
  end

  it 'map_and_sort should work with empty set' do
    expect(helper.map_and_sort(nil)).to eq({})
    expect(helper.map_and_sort([])).to eq({})
  end

  it 'map_and_sort should work for users' do
    create_list :user_with_faction, 3
    result = helper.map_and_sort(User.all)
    expect(result.size).to eq(User.count)
  end
end
