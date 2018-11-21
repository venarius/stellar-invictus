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
    
    describe 'POST update_bio' do
      it 'should redirect_to login' do
        post :update_bio
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
    
    describe 'POST update_bio' do
      it 'should update bio of user' do
        post :update_bio, params: {text: "Bla"}
        expect(response.status).to eq(200)
        expect(@user.reload.bio).to eq("Bla")
      end
      
      it 'should not update bio of user if no params' do
        post :update_bio
        expect(response.status).to eq(400)
      end
    end
  end
end