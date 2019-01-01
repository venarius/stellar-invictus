require 'rails_helper'

RSpec.describe CorporationsController, type: :controller do
  context 'with login' do
    before (:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
    end
    
    describe 'GET index' do
      before(:each) do
        @user.update_columns(corporation_role: :founder)  
      end
      
      it 'should render index' do
        get :index
        expect(response.status).to eq(200)
        expect(response).to render_template('corporations/index')
      end
      
      it 'should render index with tab' do
        get :index, params: {tab: 'info'}
        expect(response.status).to eq(200)
        expect(response).to render_template('corporations/_about')
      end
      
      it 'should render index with tab' do
        get :index, params: {tab: 'roster'}
        expect(response.status).to eq(200)
        expect(response).to render_template('corporations/_roster')
      end
      
      it 'should render index with tab' do
        get :index, params: {tab: 'finances'}
        expect(response.status).to eq(200)
        expect(response).to render_template('corporations/_finances')
      end
      
      it 'should render index with tab' do
        get :index, params: {tab: 'applications'}
        expect(response.status).to eq(200)
        expect(response).to render_template('corporations/_applications')
      end
      
      it 'should render index with tab' do
        get :index, params: {tab: 'help'}
        expect(response.status).to eq(200)
        expect(response).to render_template('corporations/_help')
      end
    end
    
    describe 'GET new' do
      it 'should render new' do
        get :new
        expect(response.status).to eq(200)
        expect(response).to render_template('corporations/new')
      end
    end
    
    describe 'POST create' do
      it 'should create new corporation' do
        post :create, params: {corporation: {name: "Text", ticker: "Test", bio: "Test", tax: 0}}
        expect(response.status).to eq(302)
        expect(response).to redirect_to(corporations_path)
        expect(Corporation.count).to eq(1)
        expect(Corporation.first.chat_room).not_to be_nil
      end
      
      it 'should not create new corporation without params' do
        post :create, params: {corporation: {name: "Text"}}
        expect(response.status).to eq(200)
        expect(response).to render_template('corporations/new')
        expect(Corporation.count).to eq(0)
      end
      
      it 'should not create new corporation if user already in corporation' do
        post :create, params: {corporation: {name: "Text", ticker: "Test", bio: "Test", tax: 0}}
        expect(response.status).to eq(302)
        post :create, params: {corporation: {name: "Text", ticker: "Test", bio: "Test", tax: 0}}
        expect(response.status).to eq(204)
        expect(Corporation.count).to eq(1)
      end
    end
    
    describe 'POST update_motd' do
      before(:each) do
        corp = FactoryBot.create(:corporation)
        @user.update_columns(corporation_id: corp.id)
      end
      
      it 'should update motd if has right ranks' do
        @user.update_columns(corporation_role: :founder)
        post :update_motd, params: {text: 'Test22'}
        expect(response.status).to eq(200)
        expect(Corporation.first.motd).to eq('Test22')
      end
      
      it 'should not update motd if has not right ranks' do
        post :update_motd, params: {text: 'Test22'}
        expect(response.status).to eq(400)
        expect(Corporation.first.motd).to eq(nil)
      end
    end
    
    describe 'POST update_corporation' do
      before(:each) do
        corp = FactoryBot.create(:corporation)
        @user.update_columns(corporation_id: corp.id)
      end
      
      it 'should update corporation if has right ranks' do
        @user.update_columns(corporation_role: :founder)
        post :update_corporation, params: {tax: 3, about: ""}
        expect(response.status).to eq(200)
        expect(Corporation.first.tax).to eq(3)
      end
      
      it 'should update corporation if has right ranks' do
        @user.update_columns(corporation_role: :founder)
        post :update_corporation, params: {tax: 1033, about: ""}
        expect(response.status).to eq(200)
        expect(Corporation.first.tax).to eq(100)
      end
      
      it 'should update corporation if has right ranks' do
        @user.update_columns(corporation_role: :founder)
        post :update_corporation, params: {tax: -3, about: ""}
        expect(response.status).to eq(200)
        expect(Corporation.first.tax).to eq(0)
      end
      
      it 'should not update corporation if has not right ranks' do
        post :update_motd, params: {tax: 3, about: ""}
        expect(response.status).to eq(400)
        expect(Corporation.first.tax).to eq(1.5)
      end
    end
    
    describe 'POST kick_user' do
      before(:each) do
        corp = FactoryBot.create(:corporation)
        @user.update_columns(corporation_id: corp.id)
        @user2 = FactoryBot.create(:user_with_faction, corporation_id: corp.id, corporation_role: 0)
      end
      
      it 'should kick user if has right ranks' do
        @user.update_columns(corporation_role: :founder)
        post :kick_user, params: {id: @user2.id}
        expect(response.status).to eq(200)
        expect(@user2.reload.corporation_id).to eq(nil)
      end
      
      it 'should not kick user if has no right ranks' do
        post :kick_user, params: {id: @user2.id}
        expect(response.status).to eq(400)
        expect(@user2.reload.corporation_id).not_to eq(nil)
      end
      
      it 'should not kick user if user has higher rank' do
        @user.update_columns(corporation_role: :commodore)
        @user2.update_columns(corporation_role: :admiral)
        post :kick_user, params: {id: @user2.id}
        expect(response.status).to eq(400)
        expect(@user2.reload.corporation_id).not_to eq(nil)
      end
      
      it 'should be able to kick self' do
        post :kick_user, params: {id: @user.id}
        expect(response.status).to eq(200)
        expect(@user.reload.corporation_id).to eq(nil)
      end
      
      it 'should destroy corporation after every user is gone' do
        @user.update_columns(corporation_role: :founder)
        post :kick_user, params: {id: @user2.id}
        expect(response.status).to eq(200)
        post :kick_user, params: {id: @user.id}
        expect(response.status).to eq(200)
        expect(Corporation.count).to eq(0)
      end
    end
    
    describe 'GET change_rank_modal' do
      before(:each) do
        corp = FactoryBot.create(:corporation)
        @user.update_columns(corporation_id: corp.id)
      end
      
      it 'should render template' do
        @user.update_columns(corporation_role: :founder)
        get :change_rank_modal, params: {id: @user.id}
        expect(response.status).to eq(200)
        expect(response).to render_template('corporations/_change_rank_modal')
      end
      
      it 'should not render template if wrong rights' do
        get :change_rank_modal, params: {id: @user.id}
        expect(response.status).to eq(400)
      end
    end
    
    describe 'POST change_rank' do
      before(:each) do
        corp = FactoryBot.create(:corporation)
        @user.update_columns(corporation_id: corp.id)
        @user2 = FactoryBot.create(:user_with_faction, corporation_id: corp.id, corporation_role: 0)
      end
      
      it 'should change rank' do
        @user.update_columns(corporation_role: :admiral)
        post :change_rank, params: {id: @user2.id, rank: 1}
        expect(response.status).to eq(200)
        expect(@user2.reload.corporation_role).to eq("lieutenant")
      end
      
      it 'should not change rank if no rights' do
        post :change_rank, params: {id: @user2.id, rank: 1}
        expect(response.status).to eq(400)
        expect(@user2.reload.corporation_role).to eq("recruit")
      end
      
      it 'should not change rank if user has higher rights' do
        @user2.update_columns(corporation_role: :admiral)
        @user.update_columns(corporation_role: :commodore)
        post :change_rank, params: {id: @user2.id, rank: 1}
        expect(response.status).to eq(400)
        expect(@user2.reload.corporation_role).to eq("admiral")
      end
      
      it 'should not change rank of only founder' do
        @user.update_columns(corporation_role: :founder)
        post :change_rank, params: {id: @user.id, rank: 1}
        expect(response.status).to eq(400)
        expect(@user.reload.corporation_role).to eq("founder")
      end
      
      it 'should change rank of founder if more than one founder' do
        @user.update_columns(corporation_role: :founder)
        @user2.update_columns(corporation_role: :founder)
        post :change_rank, params: {id: @user.id, rank: 1}
        expect(response.status).to eq(200)
        expect(@user.reload.corporation_role).to eq("lieutenant")
      end
    end
    
    describe 'POST deposit_credits' do
      before(:each) do
        corp = FactoryBot.create(:corporation)
        @user.update_columns(corporation_id: corp.id)
      end
      
      it 'should deposit credits' do
        @user.update_columns(corporation_role: :founder)
        post :deposit_credits, params: {amount: 10}
        expect(response.status).to eq(200)
        expect(@user.reload.units).to eq(0)
        expect(@user.corporation.units).to eq(10)
        expect(FinanceHistory.count).to eq(1)
      end
      
      it 'should not deposit negative credits' do
        @user.update_columns(corporation_role: :founder)
        post :deposit_credits, params: {amount: -10}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(@user.corporation.units).to eq(0)
      end
      
      it 'should not deposit more credits than user has' do
        @user.update_columns(corporation_role: :founder)
        post :deposit_credits, params: {amount: 40}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(@user.corporation.units).to eq(0)
      end
      
      it 'should not deposit credits if wrong rank' do
        post :deposit_credits, params: {amount: 10}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(@user.corporation.units).to eq(0)
      end
    end
    
    describe 'POST withdraw_credits' do
      before(:each) do
        corp = FactoryBot.create(:corporation, units: 10)
        @user.update_columns(corporation_id: corp.id)
      end
      
      it 'should withdraw credits' do
        @user.update_columns(corporation_role: :founder)
        post :withdraw_credits, params: {amount: 10}
        expect(response.status).to eq(200)
        expect(@user.reload.units).to eq(20)
        expect(@user.corporation.units).to eq(0)
        expect(FinanceHistory.count).to eq(1)
      end
      
      it 'should not withdraw negative credits' do
        @user.update_columns(corporation_role: :founder)
        post :withdraw_credits, params: {amount: -10}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(@user.corporation.units).to eq(10)
      end
      
      it 'should not withdraw more credits than corporation has' do
        @user.update_columns(corporation_role: :founder)
        post :withdraw_credits, params: {amount: 40}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(@user.corporation.units).to eq(10)
      end
      
      it 'should not withdraw credits if wrong rank' do
        post :withdraw_credits, params: {amount: 10}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(@user.corporation.units).to eq(10)
      end
    end
    
    describe 'GET Info' do
      before(:each) do
        corp = FactoryBot.create(:corporation, units: 10)
        @user.update_columns(corporation_id: corp.id)
      end
      
      it 'should render info template' do
        get :info, params: {id: @user.corporation_id}
        expect(response.status).to eq(200)
        expect(response).to render_template('corporations/_info')
      end
      
      it 'should render info template if wrong id' do
        get :info, params: {id: 1000}
        expect(response.status).to eq(200)
        expect(response.body).to eq("")
      end
    end
    
    describe 'GET apply_modal' do
      before(:each) do
        corp = FactoryBot.create(:corporation, units: 10)
        @user.update_columns(corporation_id: corp.id)
      end
      
      it 'should render apply template' do
        get :apply_modal, params: {id: @user.corporation_id}
        expect(response.status).to eq(200)
        expect(response).to render_template('corporations/_apply_modal')
      end
      
      it 'should render apply template if wrong id' do
        get :apply_modal, params: {id: 1000}
        expect(response.status).to eq(200)
        expect(response.body).to eq("")
      end
    end
    
    describe 'POST apply' do
      before(:each) do
        @corp = FactoryBot.create(:corporation, units: 10)
        @user.update_columns(corporation_id: @corp.id)
      end
      
      it 'should apply at given corporation' do
        @user.update_columns(corporation_id: nil)
        post :apply, params: {id: @corp.id, text: ""}
        expect(response.status).to eq(200)
        expect(CorpApplication.count).to eq(1)
      end
      
      it 'should not apply at given corporation if user already in corporation' do
        post :apply, params: {id: @corp.id, text: ""}
        expect(response.status).to eq(400)
        expect(CorpApplication.count).to eq(0)
      end
    end
    
    describe 'POST accept_application' do
      before(:each) do
        corp = FactoryBot.create(:corporation, units: 10)
        @user.update_columns(corporation_id: corp.id)
        @user2 = FactoryBot.create(:user_with_faction)
        @application = CorpApplication.create(user: @user2, corporation: corp, application_text: "Test")
      end
      
      it 'should accept application' do
        @user.update_columns(corporation_role: :commodore)
        post :accept_application, params: {id: @application.id}
        expect(response.status).to eq(200)
        expect(@user2.reload.corporation_id).to eq(@user.corporation_id)
        expect(CorpApplication.count).to eq(0)
      end
      
      it 'should not accept application if not right rights' do
        @user.update_columns(corporation_role: :lieutenant)
        post :accept_application, params: {id: @application.id}
        expect(response.status).to eq(400)
        expect(@user2.reload.corporation_id).to eq(nil)
        expect(CorpApplication.count).to eq(1)
      end
      
      it 'should not accept application if application is for other corp' do
        corp2 = FactoryBot.create(:corporation, units: 10, name: "Blaaa", ticker: "Blaaa")
        application = CorpApplication.create(user: @user2, corporation: corp2, application_text: "Test")
        @user.update_columns(corporation_role: :lieutenant)
        post :accept_application, params: {id: application.id}
        expect(response.status).to eq(400)
        expect(@user2.reload.corporation_id).to eq(nil)
        expect(CorpApplication.count).to eq(2)
      end
    end
    
    describe 'POST reject_application' do
      before(:each) do
        corp = FactoryBot.create(:corporation, units: 10)
        @user.update_columns(corporation_id: corp.id)
        @user2 = FactoryBot.create(:user_with_faction)
        @application = CorpApplication.create(user: @user2, corporation: corp, application_text: "Test")
      end
      
      it 'should reject application' do
        @user.update_columns(corporation_role: :commodore)
        post :reject_application, params: {id: @application.id}
        expect(response.status).to eq(200)
        expect(@user2.reload.corporation_id).to eq(nil)
        expect(CorpApplication.count).to eq(0)
      end
      
      it 'should not reject application if not right rights' do
        @user.update_columns(corporation_role: :lieutenant)
        post :reject_application, params: {id: @application.id}
        expect(response.status).to eq(400)
        expect(@user2.reload.corporation_id).to eq(nil)
        expect(CorpApplication.count).to eq(1)
      end
      
      it 'should not reject application if application is for other corp' do
        corp2 = FactoryBot.create(:corporation, units: 10, name: "Blaaa", ticker: "Blaaa")
        application = CorpApplication.create(user: @user2, corporation: corp2, application_text: "Test")
        @user.update_columns(corporation_role: :lieutenant)
        post :reject_application, params: {id: application.id}
        expect(response.status).to eq(400)
        expect(@user2.reload.corporation_id).to eq(nil)
        expect(CorpApplication.count).to eq(2)
      end
    end
    
    describe 'POST disband' do
      before(:each) do
        corp = FactoryBot.create(:corporation, units: 10)
        @user.update_columns(corporation_id: corp.id, corporation_role: :founder)
        @user2 = FactoryBot.create(:user_with_faction, corporation_id: corp.id, corporation_role: :recruit)
      end
      
      it 'should disband corporation' do
        post :disband
        expect(response.status).to eq(200)
        expect(@user.reload.corporation_id).to eq(nil)
        expect(@user2.reload.corporation_id).to eq(nil)
        expect(Corporation.count).to eq(0)
      end
      
      it 'should not disband corporation if not founder' do
        @user.update_columns(corporation_role: :admiral)
        post :disband
        expect(response.status).to eq(400)
        expect(@user.reload.corporation_id).not_to eq(nil)
        expect(@user2.reload.corporation_id).not_to eq(nil)
        expect(Corporation.count).to eq(1)
      end
    end
  end
end