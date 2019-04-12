require 'rails_helper'

RSpec.describe PollsController, type: :controller do
  context 'with login' do
    let(:user) { create :user_with_faction, units: 1000 }
    let(:poll) { create :poll, status: :active }
    before (:each) do
      sign_in user
    end

    describe 'POST create' do
      it 'should create poll as admin' do
        user.update(admin: true)
        post :create, params: { question: 'Test', link: 'Test' }
        expect(response).to have_http_status(:ok)
        expect(Poll.count).to eq(1)
      end

      it 'should not create poll as non admin' do
        post :create, params: { question: 'Test', link: 'Test' }
        expect(response).to have_http_status(:bad_request)
        expect(Poll.count).to eq(0)
      end

      it 'should not create poll as admin but with no params' do
        user.update(admin: true)
        post :create
        expect(response).to have_http_status(:bad_request)
        expect(Poll.count).to eq(0)
      end
    end

    describe 'POST upvote' do
      it 'should upvote poll' do
        post :upvote, params: { id: poll.id }
        expect(response).to have_http_status(:ok)
        expect(poll.get_upvotes.size).to eq(1)
      end

      it 'should not upvote poll if not active' do
        poll.waiting!
        post :upvote, params: { id: poll.id }
        expect(response).to have_http_status(:ok)
        expect(poll.get_upvotes.size).to eq(0)
      end

      it 'should not upvote poll if not enough credits' do
        user.update(units: 100)
        post :upvote, params: { id: poll.id }
        expect(response).to have_http_status(:bad_request)
        expect(poll.get_upvotes.size).to eq(0)
      end
    end

    describe 'POST downvote' do
      it 'should upvote poll' do
        post :downvote, params: { id: poll.id }
        expect(response).to have_http_status(:ok)
        expect(poll.get_downvotes.size).to eq(1)
      end

      it 'should not upvote poll if not active' do
        poll.waiting!
        post :downvote, params: { id: poll.id }
        expect(response).to have_http_status(:ok)
        expect(poll.get_downvotes.size).to eq(0)
      end

      it 'should not downvote poll if not enough credits' do
        user.update(units: 100)
        post :downvote, params: { id: poll.id }
        expect(response).to have_http_status(:bad_request)
        expect(poll.get_downvotes.size).to eq(0)
      end
    end

    describe 'POST move_up' do
      it 'should move poll up as admin' do
        poll.waiting!
        user.update(admin: true)
        post :move_up, params: { id: poll.id }
        expect(response).to have_http_status(:ok)
        expect(poll.reload.in_progress?).to be_truthy
      end

      it 'should not move poll up as non admin' do
        poll.waiting!
        post :move_up, params: { id: poll.id }
        expect(response).to have_http_status(:ok)
        expect(poll.reload.in_progress?).to be_falsey
      end

      it 'should not do anything if no params' do
        poll.waiting!
        post :move_up
        expect(response).to have_http_status(:bad_request)
        expect(poll.reload.in_progress?).to be_falsey
      end
    end

    describe 'POST delete' do
      it 'should delete post if admin' do
        user.update(admin: true)
        post :delete, params: { id: poll.id }
        expect(response).to have_http_status(:ok)
        expect(Poll.count).to eq(0)
      end

      it 'should not delete post if non admin' do
        post :delete, params: { id: poll.id }
        expect(response).to have_http_status(:ok)
        expect(Poll.count).to eq(1)
      end
    end
  end
end
