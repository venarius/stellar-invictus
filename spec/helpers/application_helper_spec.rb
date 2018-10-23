require 'rails_helper'

describe ApplicationHelper do
  describe 'navbar_item' do
    it 'should return html for navbar' do
      allow(self).to receive('current_page?').and_return("/")
      expect(navbar_item(root_path, 'navbar.home')).to include("Home")
    end
  end
end