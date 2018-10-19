require 'rails_helper'

RSpec.describe FactionsController, type: :controller do
    context 'without login' do
        describe 'GET index' do
            it 'should redirect_to new_user_session_path' do
                 get :index
                 expect(response.code).to eq("302")
                 expect(response).to redirect_to("/connect")
            end
        end
        
        describe 'POST choose_faction' do
            it 'should redirect_to new_user_session_path' do
                 post :choose_faction, params: {id: 1}
                 expect(response.code).to eq("302")
                 expect(response).to redirect_to("/connect")
            end
        end
    end
    
    context 'with login' do
        before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:user]
            sign_in FactoryBot.create(:user)
        end
        
        describe 'GET index' do
            it 'should render index' do
                 get :index
                 expect(response.code).to eq("200")
                 expect(assigns[:factions].length).to eq(3)
            end
            
            it 'should redirect_to root_path if already has faction' do
                sign_in FactoryBot.create(:user, faction: Faction.first)
                
                get :index
                expect(response.code).to eq("302")
                expect(response).to redirect_to("/")
            end
        end
        
        describe 'POST choose_faction' do
            it 'should redirect_to root_path' do
                 post :choose_faction, params: {id: 1}
                 expect(response.code).to eq("302")
                 expect(response).to redirect_to("/")
            end
            
            it 'should redirect_to root_path if already has faction' do
                @user = FactoryBot.create(:user, faction: Faction.first)
                sign_in @user
                
                post :choose_faction, params: {id: 2}
                expect(response.code).to eq("302")
                expect(response).to redirect_to("/")
                expect(@user.faction_id).to eq(1)
            end
        end
    end
end