require 'rails_helper'

RSpec.describe CorporationsController, type: :controller do
  context 'with login' do
    let(:user) { create :user_with_faction }
    before (:each) do
      sign_in user
    end

    describe 'GET index' do
      before(:each) do
        user.update(corporation_role: :founder, corporation: create(:corporation))
      end

      it 'should render index' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/index')
      end

      it 'should render index with tab' do
        get :index, params: { tab: 'info' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/_about')
      end

      it 'should render index with tab' do
        get :index, params: { tab: 'roster' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/_roster')
      end

      it 'should render index with tab' do
        get :index, params: { tab: 'finances' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/_finances')
      end

      it 'should render index with tab' do
        get :index, params: { tab: 'applications' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/_applications')
      end

      it 'should render index with tab' do
        get :index, params: { tab: 'help' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/_help')
      end
    end

    describe 'GET sort_roster' do
      let(:corporation) { create :corporation }

      before(:each) do
        user.update(corporation_role: :founder)
        corporation.users << user
      end

      it 'should render sorted roster' do
        get :sort_roster, params: { columns: 'full_name', direction: 'asc' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/_roster')
      end
    end

    describe 'GET new' do
      it 'should render new' do
        get :new
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/new')
      end
    end

    describe 'POST create' do
      it 'should create new corporation' do
        expect {
          post :create, params: { corporation: { name: 'Text', ticker: 'Test', bio: 'Test', tax: 0 } }
          expect(response).to redirect_to(corporations_path)
        }.to change { Corporation.count }.by(1)
        expect(user.reload.corporation.chat_room).to be_present
      end

      it 'should not create new corporation without params' do
        post :create, params: { corporation: { name: 'Text' } }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/new')
        expect(Corporation.count).to eq(0)
      end

      it 'should not create new corporation if user already in corporation' do
        post :create, params: { corporation: { name: 'Text', ticker: 'Test', bio: 'Test', tax: 0 } }
        expect(response.status).to eq(302)
        post :create, params: { corporation: { name: 'Text', ticker: 'Test', bio: 'Test', tax: 0 } }
        expect(response.status).to eq(204)
        expect(Corporation.count).to eq(1)
      end
    end

    describe 'POST update_motd' do
      before(:each) do
        user.update(corporation: create(:corporation))
      end

      it 'should update motd if has right ranks' do
        user.update(corporation_role: :founder)
        post :update_motd, params: { text: 'Test22' }
        expect(response).to have_http_status(:ok)
        expect(Corporation.first.motd).to eq('Test22')
      end

      it 'should not update motd if has not right ranks' do
        post :update_motd, params: { text: 'Test22' }
        expect(response).to have_http_status(:bad_request)
        expect(Corporation.first.motd).to eq(nil)
      end
    end

    describe 'POST update_corporation' do
      let(:corp) { create(:corporation) }
      before(:each) do
        user.update(corporation: corp)
      end

      it 'should update corporation if has right ranks' do
        user.update(corporation_role: :founder)
        post :update_corporation, params: { tax: 3 }
        expect(response).to have_http_status(:ok)
        expect(corp.reload.tax).to eq(3)
      end

      it 'should update corporation if has right ranks' do
        user.update(corporation_role: :founder)
        post :update_corporation, params: { tax: 1033 }
        expect(response).to have_http_status(:ok)
        expect(corp.reload.tax).to eq(100)
      end

      it 'should update corporation if has right ranks' do
        user.update(corporation_role: :founder)
        post :update_corporation, params: { tax: -3 }
        expect(response).to have_http_status(:ok)
        expect(corp.reload.tax).to eq(0)
      end

      it 'should not update corporation if has not right ranks' do
        expect {
          post :update_corporation, params: { tax: 3, about: '' }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { corp.reload.tax }
      end

      it 'should not update corporation if no params given' do
        post :update_corporation, params: {}
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST kick_user' do
      let(:corp) { create(:corporation) }
      let!(:user2) { create(:user_with_faction, corporation: corp, corporation_role: :recruit) }

      before(:each) do
        user.update(corporation: corp)
      end

      it 'should kick user if has right ranks' do
        user.update(corporation_role: :founder)
        post :kick_user, params: { id: user2.id }
        expect(response).to have_http_status(:ok)
        expect(user2.reload.corporation_id).to eq(nil)
      end

      it 'should not kick user if has no right ranks' do
        post :kick_user, params: { id: user2.id }
        expect(response).to have_http_status(:bad_request)
        expect(user2.reload.corporation_id).not_to eq(nil)
      end

      it 'should not kick user if user has higher rank' do
        user.update(corporation_role: :commodore)
        user2.update(corporation_role: :admiral)
        post :kick_user, params: { id: user2.id }
        expect(response).to have_http_status(:bad_request)
        expect(user2.reload.corporation_id).not_to eq(nil)
      end

      it 'should be able to kick self' do
        post :kick_user, params: { id: user.id }
        expect(response).to have_http_status(:ok)
        expect(user.reload.corporation).to eq(nil)
      end

      it 'should destroy corporation after every user is gone' do
        user.update(corporation_role: :founder)
        post :kick_user, params: { id: user2.id }
        expect(response).to have_http_status(:ok)

        expect {
          post :kick_user, params: { id: user.id }
          expect(response).to have_http_status(:ok)
        }.to change { Corporation.count }.by(-1)
      end
    end

    describe 'GET change_rank_modal' do
      before(:each) do
        user.update(corporation: create(:corporation))
      end

      it 'should render template' do
        user.update(corporation_role: :founder)
        get :change_rank_modal, params: { id: user.id }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/_change_rank_modal')
      end

      it 'should not render template if wrong rights' do
        get :change_rank_modal, params: { id: user.id }
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST change_rank' do
      let(:corp) { create(:corporation) }
      let!(:user2) { create(:user_with_faction, corporation: corp, corporation_role: :recruit) }

      before(:each) do
        user.update(corporation: corp)
      end

      it 'should change rank' do
        user.update(corporation_role: :admiral)
        post :change_rank, params: { id: user2.id, rank: 1 }
        expect(response).to have_http_status(:ok)
        expect(user2.reload.corporation_role).to eq('lieutenant')
      end

      it 'should not change rank if no rights' do
        post :change_rank, params: { id: user2.id, rank: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(user2.reload.corporation_role).to eq('recruit')
      end

      it 'should not change rank if user has higher rights' do
        user2.update(corporation_role: :admiral)
        user.update(corporation_role: :commodore)
        post :change_rank, params: { id: user2.id, rank: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(user2.reload.corporation_role).to eq('admiral')
      end

      it 'should not change rank of only founder' do
        user.update(corporation_role: :founder)
        post :change_rank, params: { id: user.id, rank: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.corporation_role).to eq('founder')
      end

      it 'should change rank of founder if more than one founder' do
        user.update(corporation_role: :founder)
        user2.update(corporation_role: :founder)
        post :change_rank, params: { id: user.id, rank: 1 }
        expect(response).to have_http_status(:ok)
        expect(user.reload.corporation_role).to eq('lieutenant')
      end
    end

    describe 'POST deposit_credits' do
      before(:each) do
        user.update(corporation: create(:corporation))
      end

      it 'should deposit credits' do
        user.update(corporation_role: :founder)
        post :deposit_credits, params: { amount: 10 }
        expect(response).to have_http_status(:ok)
        expect(user.reload.units).to eq(0)
        expect(user.corporation.units).to eq(10)
        expect(FinanceHistory.count).to eq(1)
      end

      it 'should not deposit negative credits' do
        user.update(corporation_role: :founder)
        post :deposit_credits, params: { amount: -10 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(user.corporation.units).to eq(0)
      end

      it 'should not deposit more credits than user has' do
        user.update(corporation_role: :founder)
        post :deposit_credits, params: { amount: 40 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(user.corporation.units).to eq(0)
      end

      it 'should not deposit credits if wrong rank' do
        post :deposit_credits, params: { amount: 10 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(user.corporation.units).to eq(0)
      end
    end

    describe 'POST withdraw_credits' do
      before(:each) do
        user.update(corporation: create(:corporation, units: 10))
      end

      it 'should withdraw credits' do
        user.update(corporation_role: :founder)
        post :withdraw_credits, params: { amount: 10 }
        expect(response).to have_http_status(:ok)
        expect(user.reload.units).to eq(20)
        expect(user.corporation.units).to eq(0)
        expect(FinanceHistory.count).to eq(1)
      end

      it 'should not withdraw negative credits' do
        user.update(corporation_role: :founder)
        post :withdraw_credits, params: { amount: -10 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(user.corporation.units).to eq(10)
      end

      it 'should not withdraw more credits than corporation has' do
        user.update(corporation_role: :founder)
        post :withdraw_credits, params: { amount: 40 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(user.corporation.units).to eq(10)
      end

      it 'should not withdraw credits if wrong rank' do
        post :withdraw_credits, params: { amount: 10 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(user.corporation.units).to eq(10)
      end
    end

    describe 'GET Info' do
      before(:each) do
        user.update(corporation: create(:corporation, units: 10))
      end

      it 'should render info template' do
        get :info, params: { id: user.corporation_id }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/_info')
      end

      it 'should render info template if wrong id' do
        get :info, params: { id: 1000 }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('')
      end
    end

    describe 'GET apply_modal' do
      before(:each) do
        user.update(corporation: create(:corporation, units: 10))
      end

      it 'should render apply template' do
        get :apply_modal, params: { id: user.corporation_id }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/_apply_modal')
      end

      it 'should render apply template if wrong id' do
        get :apply_modal, params: { id: 1000 }
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('')
      end
    end

    describe 'POST apply' do
      let!(:corp) { create(:corporation, units: 10) }
      before(:each) do
        user.update(corporation: corp)
      end

      it 'should apply at given corporation WITH TEXT' do
        user.update(corporation_id: nil)
        expect {
          post :apply, params: { id: corp.id, text: 'My application letter' }
          expect(response).to have_http_status(:ok)
        }.to change { CorpApplication.count }.by(1)
      end

      it 'should apply at given corporation with NO TEXT' do
        user.update(corporation_id: nil)
        expect {
          post :apply, params: { id: corp.id }
          expect(response).to have_http_status(:ok)
        }.to change { CorpApplication.count }.by(1)
      end

      it 'should not apply at given corporation if user already in corporation' do
        expect {
          post :apply, params: { id: corp.id, text: '' }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { CorpApplication.count }
      end

      it 'should not apply if no params given' do
        post :apply, params: {}
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST accept_application' do
      let(:corp) { create(:corporation, units: 10) }
      let(:user2) { create(:user_with_faction) }
      let!(:application) { create :corp_application, user: user2, corporation: corp, application_text: 'Test' }

      before(:each) do
        user.update(corporation: corp)
      end

      it 'should accept application' do
        user.update(corporation_role: :commodore)
        expect {
          post :accept_application, params: { id: application.id }
          expect(response).to have_http_status(:ok)
          expect(user2.reload.corporation_id).to eq(user.corporation_id)
        }.to change { CorpApplication.count }.by(-1)
      end

      it 'should NOT accept application if not right rights' do
        user.update(corporation_role: :lieutenant)
        expect {
          post :accept_application, params: { id: application.id }
          expect(response).to have_http_status(:bad_request)
          expect(user2.reload.corporation_id).to eq(nil)
        }.not_to change { CorpApplication.count }
      end

      it 'should NOT accept application if application is for other corp' do
        corp2 = create(:corporation, units: 10, name: 'Blaaa', ticker: 'Blaaa')
        application = create(:corp_application, user: user2, corporation: corp2, application_text: 'Test')
        user.update(corporation_role: :lieutenant)
        expect {
          post :accept_application, params: { id: application.id }
          expect(response).to have_http_status(:bad_request)
          expect(user2.reload.corporation_id).to eq(nil)
        }.not_to change { CorpApplication.count }
      end
    end

    describe 'POST reject_application' do
      let(:corp) { create(:corporation, units: 10) }
      let(:user2) { create(:user_with_faction) }
      let!(:application) { create :corp_application, user: user2, corporation: corp, application_text: 'Test' }

      before(:each) do
        user.update(corporation: corp)
      end

      it 'success' do
        user.update(corporation_role: :commodore)
        expect {
          post :reject_application, params: { id: application.id }
          expect(response).to have_http_status(:ok)
          expect(user2.reload.corporation_id).to eq(nil)
        }.to change { CorpApplication.count }.by(-1)
      end

      it 'fail if not right rights' do
        user.update(corporation_role: :lieutenant)
        expect {
          post :reject_application, params: { id: application.id }
          expect(response).to have_http_status(:bad_request)
          expect(user2.reload.corporation_id).to eq(nil)
        }.not_to change { CorpApplication.count }
      end

      it 'fail if application is for other corp' do
        corp2 = create(:corporation, units: 10, name: 'Blaaa', ticker: 'Blaaa')
        application = create(:corp_application, user: user2, corporation: corp2, application_text: 'Test')
        user.update(corporation_role: :lieutenant)
        expect {
          post :reject_application, params: { id: application.id }
          expect(response).to have_http_status(:bad_request)
          expect(user2.reload.corporation_id).to eq(nil)
        }.not_to change { CorpApplication.count }
      end
    end

    describe 'POST disband' do
      let(:corp) { create(:corporation, units: 10) }
      let!(:user2) { create(:user_with_faction, corporation: corp, corporation_role: :recruit) }

      before(:each) do
        user.update(corporation_id: corp.id, corporation_role: :founder)
      end

      it 'should disband corporation' do
        post :disband
        expect(response).to have_http_status(:ok)
        expect(user.reload.corporation_id).to eq(nil)
        expect(user2.reload.corporation_id).to eq(nil)
        expect(Corporation.count).to eq(0)
      end

      it 'should not disband corporation if not founder' do
        user.update(corporation_role: :admiral)
        post :disband
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.corporation_id).not_to eq(nil)
        expect(user2.reload.corporation_id).not_to eq(nil)
        expect(Corporation.count).to eq(1)
      end
    end

    describe 'POST search' do
      it 'should render template' do
        post :search, params: { search: 'test' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('corporations/_search')
      end

      it 'should not render if no params' do
        post :search
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
