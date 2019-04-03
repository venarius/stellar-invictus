require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do
  describe 'GET home' do
    it 'should render home view' do
      get :home
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET credits' do
    it 'should render credits view' do
      get :credits
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET map' do
    it 'should redirect when not logged in' do
      get :map
      expect(response.code).to eq('302')
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'should render map when user is logged in' do
      @user = create(:user_with_faction)
      sign_in @user

      get :map
      expect(response).to have_http_status(:ok)
    end
  end
end
