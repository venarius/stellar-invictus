require 'rails_helper'

RSpec.describe PollsController, type: :controller do
  context 'with login' do
    before (:each) do
      @user = FactoryBot.create(:user_with_faction, units: 1000)
      sign_in @user
    end
    
    describe 'POST create' do
      it 'should create poll as admin' do
        @user.update_columns(admin: true)
        post :create, params: {question: "Test", link: "Test"}
        expect(response.status).to eq(200)
        expect(Poll.count).to eq(1)
      end
      
      it 'should not create poll as non admin' do
        post :create, params: {question: "Test", link: "Test"}
        expect(response.status).to eq(400)
        expect(Poll.count).to eq(0)
      end
      
      it 'should not create poll as admin but with no params' do
        @user.update_columns(admin: true)
        post :create
        expect(response.status).to eq(400)
        expect(Poll.count).to eq(0)
      end
    end
    
    describe 'POST upvote' do
      before (:each) do
        @poll = FactoryBot.create(:poll, status: :active)
      end
    
      it 'should upvote poll' do
        post :upvote, params: {id: @poll.id}
        expect(response.status).to eq(200)
        expect(@poll.get_upvotes.size).to eq(1)
      end
      
      it 'should not upvote poll if not active' do
        @poll.waiting!
        post :upvote, params: {id: @poll.id}
        expect(response.status).to eq(200)
        expect(@poll.get_upvotes.size).to eq(0)
      end
      
      it 'should not upvote poll if not enough credits' do
        @user.update_columns(units: 100)
        post :upvote, params: {id: @poll.id}
        expect(response.status).to eq(400)
        expect(@poll.get_upvotes.size).to eq(0)
      end
    end
    
    describe 'POST downvote' do
      before (:each) do
        @poll = FactoryBot.create(:poll, status: :active)
      end
    
      it 'should upvote poll' do
        post :downvote, params: {id: @poll.id}
        expect(response.status).to eq(200)
        expect(@poll.get_downvotes.size).to eq(1)
      end
      
      it 'should not upvote poll if not active' do
        @poll.waiting!
        post :downvote, params: {id: @poll.id}
        expect(response.status).to eq(200)
        expect(@poll.get_downvotes.size).to eq(0)
      end
      
      it 'should not downvote poll if not enough credits' do
        @user.update_columns(units: 100)
        post :downvote, params: {id: @poll.id}
        expect(response.status).to eq(400)
        expect(@poll.get_downvotes.size).to eq(0)
      end
    end
    
    describe 'POST move_up' do
      before (:each) do
        @poll = FactoryBot.create(:poll, status: :active)
      end
      
      it 'should move poll up as admin' do
        @poll.waiting!
        @user.update_columns(admin: true)
        post :move_up, params: {id: @poll.id}
        expect(response.status).to eq(200)
        expect(@poll.reload.in_progress?).to be_truthy
      end
      
      it 'should not move poll up as non admin' do
        @poll.waiting!
        post :move_up, params: {id: @poll.id}
        expect(response.status).to eq(200)
        expect(@poll.reload.in_progress?).to be_falsey
      end
      
      it 'should not do anything if no params' do
        @poll.waiting!
        post :move_up
        expect(response.status).to eq(400)
        expect(@poll.reload.in_progress?).to be_falsey
      end
    end
    
    describe 'POST delete' do
      before (:each) do
        @poll = FactoryBot.create(:poll, status: :active)
      end
      
      it 'should delete post if admin' do
        @user.update_columns(admin: true)
        post :delete, params: {id: @poll.id}
        expect(response.status).to eq(200)
        expect(Poll.count).to eq(0)
      end
      
      it 'should not delete post if non admin' do
        post :delete, params: {id: @poll.id}
        expect(response.status).to eq(200)
        expect(Poll.count).to eq(1)
      end
    end
  end
end