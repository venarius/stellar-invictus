require 'rails_helper'

RSpec.describe MarketController, type: :controller do
  context 'without login' do
    describe 'GET list' do
      it 'should redirect_to new_user_session_path' do
        get :list
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'GET search' do
      it 'should redirect_to new_user_session_path' do
        get :search
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST buy' do
      it 'should redirect_to new_user_session_path' do
        post :buy
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST sell' do
      it 'should redirect_to new_user_session_path' do
        post :sell
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST appraisal' do
      it 'should redirect_to new_user_session_path' do
        post :appraisal
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  context 'with login' do
    before(:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
      @user.update_columns(location_id: Location.where(location_type: 'station').first.id, docked: true)
    end
    
    describe 'GET list' do
      it 'should render template' do
        get :list, params: {loader: 'test'}
        expect(response.status).to eq(200)
        expect(response).to render_template('stations/market/_list')
      end
      
      it 'should not render template if no params' do
        get :list
        expect(response.status).to eq(400)
      end
    end
    
    describe 'GET search' do
      it 'should render template' do
        get :search, params: {search: 'test'}
        expect(response.status).to eq(200)
        expect(response).to render_template('stations/market/_list')
      end
      
      it 'should not render template if no params' do
        get :search
        expect(response.status).to eq(400)
      end
    end
    
    describe 'POST appraisal' do
      it 'should response with price' do
        post :appraisal, params: {loader: 'asteroid.nickel_ore', quantity: "10", type: "item"}
        expect(response.status).to eq(200)
        expect(response.body).to include("price")
      end
      
      it 'should not response with price if shit given' do
        post :appraisal, params: {loader: 'noot.noot', quantity: "10", type: "noot"}
        expect(response.status).to eq(400)
      end
    end
    
    describe 'POST buy' do
      before(:each) do
        @user.update_columns(units: 5000)
        @item = MarketListing.create(location: @user.location, loader: 'asteroid.nickel_ore', listing_type: 'item', price: 1000, amount: 1)  
        @ship = MarketListing.create(location: @user.location, loader: 'Chronos', listing_type: 'ship', price: 2000, amount: 1)  
      end
      
      it 'should buy item if has enough money' do
        post :buy, params: {id: @item.id, amount: "1"}
        expect(response.status).to eq(200)
        expect(@user.reload.units).to eq(4000)
        expect(Item.count).to eq(1)
      end
      
      it 'should not buy item if not docked' do
        @user.update_columns(docked: false)
        post :buy, params: {id: @item.id, amount: "1"}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(5000)
        expect(Item.count).to eq(0)
      end
      
      it 'should not buy item if docked elsewhere' do
        @user.update_columns(location_id: Location.last)
        post :buy, params: {id: @item.id, amount: "1"}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(5000)
        expect(Item.count).to eq(0)
      end
      
      it 'should buy ship if has enough money' do
        post :buy, params: {id: @ship.id, amount: "1"}
        expect(response.status).to eq(200)
        expect(@user.reload.units).to eq(3000)
        expect(Spaceship.count).to eq(2)
        expect(Item.count).to eq(0)
      end
      
      it 'should not buy faction ship if not enough reputation' do
        listing = MarketListing.create(location: @user.location, listing_type: 'ship', price: '1', loader: 'Behemoth', amount: 1)
        post :buy, params: {id: listing.id, amount: "1"}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(5000)
        expect(Spaceship.count).to eq(1)
        expect(Item.count).to eq(0)
      end
      
      it 'should buy faction ship if enough reputation' do
        listing = MarketListing.create(location: @user.location, listing_type: 'ship', price: '1', loader: 'Behemoth', amount: 1)
        @user.update_columns(reputation_1: 25)
        post :buy, params: {id: listing.id, amount: "1"}
        expect(response.status).to eq(200)
        expect(@user.reload.units).to eq(4999)
        expect(Spaceship.count).to eq(2)
        expect(Item.count).to eq(0)
      end
      
      it 'should not buy item if not enough money' do
        @user.update_columns(units: 50)
        post :buy, params: {id: @item.id, amount: "1"}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(50)
      end
      
      it 'should not buy item if in other location' do
        @user.update_columns(location_id: Location.last.id)
        post :buy, params: {id: @item.id, amount: "1"}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(5000)
      end
      
      it 'should not buy more items than available' do
        post :buy, params: {id: @item.id, amount: "3"}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(5000)
      end
    end
    
    describe 'POST sell' do
      before(:each) do
        @item = Item.create(location: @user.location, user: @user, loader: 'asteroid.nickel_ore')
        @ship = Spaceship.create(name: 'Nano', user: @user, hp: 50, location: @user.location)
      end
      
      it 'should sell item' do
        post :sell, params: {loader: 'asteroid.nickel_ore', type: 'item', quantity: '1'}
        expect(response.status).to eq(200)
        expect(@user.reload.units).to eq(16)
        expect(Item.count).to eq(0)
      end
      
      it 'should not sell item if not docked' do
        @user.update_columns(docked: false)
        post :sell, params: {loader: 'asteroid.nickel_ore', type: 'item', quantity: '1'}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(Item.count).to eq(1)
      end
      
      it 'should not sell item if user docked elsewhere' do
        @user.update_columns(location_id: Location.last.id)
        post :sell, params: {loader: 'asteroid.nickel_ore', type: 'item', quantity: '1'}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(Item.count).to eq(1)
      end
      
      it 'should sell item on price of listing' do
        MarketListing.create(location: @user.location, loader: 'asteroid.nickel_ore', listing_type: 'item', price: 1000, amount: 1)  
        post :sell, params: {loader: 'asteroid.nickel_ore', type: 'item', quantity: '1'}
        expect(response.status).to eq(200)
        expect(@user.reload.units).to eq(16)
        expect(Item.count).to eq(0)
      end
      
      it 'should sell not more items than user has' do
        post :sell, params: {loader: 'asteroid.nickel_ore', type: 'item', quantity: '2'}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(Item.count).to eq(1)
      end
      
      it 'should sell ship' do
        post :sell, params: {loader: @ship.name, id: @ship.id, type: 'ship', quantity: '1'}
        expect(response.status).to eq(200)
        expect(@user.reload.units).to eq(10)
        expect(Spaceship.count).to eq(1)
      end
      
      it 'should not sell ship if selling more' do
        post :sell, params: {loader: @ship.name, id: @ship.id, type: 'ship', quantity: '2'}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(Spaceship.count).to eq(2)
      end
      
      it 'should not sell ship which is not here' do
        @ship.update_columns(location_id: Location.last.id)
        post :sell, params: {loader: @ship.name, id: @ship.id, type: 'ship', quantity: '1'}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(Spaceship.count).to eq(2)
      end
      
      it 'should not sell active spaceship' do
        post :sell, params: {loader: @user.active_spaceship.name, id: @user.active_spaceship.id, type: 'ship', quantity: '1'}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(Spaceship.count).to eq(2)
      end
      
      it 'should not sell shit' do
        post :sell, params: {loader: 'Blub', type: 'ship', quantity: '1'}
        expect(response.status).to eq(400)
        expect(@user.reload.units).to eq(10)
        expect(Spaceship.count).to eq(2)
      end
    end
  end
end