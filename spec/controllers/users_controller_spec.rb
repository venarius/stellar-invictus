require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  context 'without login' do
    describe 'GET info' do
      it 'should redirect_to login' do
        get :info, params: {id: 1}
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  context 'with login' do 
    before(:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
    end
    
    describe 'GET info' do
      it 'should render partial with valid id given' do
        get :info, params: {id: @user.id}
        expect(response.code).to eq('200')
        expect(response.body).to render_template(:partial => '_info')
      end
      
      it 'should render nothing with invalid id given' do
        get :info, params: {id: 2020}
        expect(response.code).to eq('200')
        expect(response.body).to eq('')
      end
    end
  end
end