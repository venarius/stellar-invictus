require 'rails_helper'

RSpec.describe SystemsController, type: :controller do
  context 'without login' do
    describe 'GET info' do
      it 'should redirect_to login' do
        get :info, params: {id: 1}
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST route' do
      it 'should redirect_to login' do
        post :route
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST clear_route' do
      it 'should redirect_to login' do
        post :clear_route
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
      it 'should render template info' do
        get :info, params: {id: 1}
        expect(response.status).to eq(200)
        expect(response).to render_template('systems/_info')
      end
      
      it 'should respond with 400 if no params' do
        get :info
        expect(response.status).to eq(400)
      end
    end
  
    describe 'POST route' do
      it 'should plot route if params given' do
        post :route, params: {id: System.last.id}
        expect(response.status).to eq(200)
        expect(response.body).to include("[1,4]")
      end
      
      it 'should respond 400 if no params given' do
        post :route
        expect(response.status).to eq(400)
      end
    end
    
    describe 'POST clear_route' do
      it 'should clear route of user' do
        @user.update_columns(route: ["1", "2", "3"])
        post :clear_route
        expect(response.status).to eq(200)
        expect(@user.reload.route).to eq([])
      end
    end
  end
  
end