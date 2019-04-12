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
    let(:user) { create :user_with_faction, location: Location.station.first, docked: true }
    before(:each) do
      sign_in user
    end

    describe 'GET list' do
      it 'should render template' do
        get :list, params: { loader: 'test' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('stations/market/_list')
      end

      it 'should not render template if no params' do
        get :list
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'GET search' do
      it 'should render template' do
        get :search, params: { search: 'test' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('stations/market/_list')
      end

      it 'should not render template if no params' do
        get :search
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST appraisal' do
      it 'should response with price' do
        post :appraisal, params: { loader: 'asteroid.nickel_ore', quantity: '10', type: 'item' }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('price')
      end

      it 'should not response with price if shit given' do
        post :appraisal, params: { loader: 'noot.noot', quantity: '10', type: 'noot' }
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST buy' do
      let(:item) { create :market_listing, location: user.location, loader: 'asteroid.nickel_ore', listing_type: :item, price: 1000, amount: 1 }
      let(:ship) { create :market_listing, location: user.location, loader: 'Chronos', listing_type: :ship, price: 2000, amount: 1 }

      before(:each) do
        user.update(units: 5000)
      end

      it 'should buy item if has enough money' do
        post :buy, params: { id: item.id, amount: 1 }
        expect(response).to have_http_status(:ok)
        expect(user.reload.units).to eq(4000)
        expect(Item.count).to eq(1)
      end

      it 'should not buy item if not docked' do
        user.update(docked: false)
        post :buy, params: { id: item.id, amount: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(5000)
        expect(Item.count).to eq(0)
      end

      it 'should not buy item if docked elsewhere' do
        item
        user.update(location: Location.station.last)
        post :buy, params: { id: item.id, amount: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(5000)
        expect(Item.count).to eq(0)
      end

      it 'should buy ship if has enough money' do
        post :buy, params: { id: ship.id, amount: 1 }
        expect(response).to have_http_status(:ok)
        expect(user.reload.units).to eq(3000)
        expect(Spaceship.count).to eq(2)
        expect(Item.count).to eq(0)
      end

      it 'should not buy faction ship if not enough reputation' do
        listing = create :market_listing, location: user.location, listing_type: :ship, price: 1, loader: 'Behemoth', amount: 1
        post :buy, params: { id: listing.id, amount: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(5000)
        expect(Spaceship.count).to eq(1)
        expect(Item.count).to eq(0)
      end

      it 'should buy faction ship if enough reputation' do
        listing = create :market_listing, location: user.location, listing_type: :ship, price: 1, loader: 'Behemoth', amount: 1
        user.update(reputation_1: 25)
        post :buy, params: { id: listing.id, amount: 1 }
        expect(response).to have_http_status(:ok)
        expect(user.reload.units).to eq(4999)
        expect(Spaceship.count).to eq(2)
        expect(Item.count).to eq(0)
      end

      it 'should not buy item if not enough money' do
        user.update(units: 50)
        post :buy, params: { id: item.id, amount: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(50)
      end

      it 'should not buy item if in other location' do
        item
        user.update(location: Location.station.last)
        post :buy, params: { id: item.id, amount: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(5000)
      end

      it 'should not buy more items than available' do
        post :buy, params: { id: item.id, amount: 3 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(5000)
      end
    end

    describe 'POST sell' do
      let!(:item) { create :item, location: user.location, user: user, loader: 'asteroid.nickel_ore' }
      let!(:ship) { create :spaceship, name: 'Nano', user: user, hp: 50, location: user.location }

      it 'should sell item' do
        post :sell, params: { loader: 'asteroid.nickel_ore', type: 'item', quantity: 1 }
        expect(response).to have_http_status(:ok)
        expect(user.reload.units).to eq(18)
        expect(Item.count).to eq(0)
      end

      it 'should not sell item if not docked' do
        user.update(docked: false)
        post :sell, params: { loader: 'asteroid.nickel_ore', type: 'item', quantity: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(Item.count).to eq(1)
      end

      it 'should not sell item if user docked elsewhere' do
        user.update(location_id: Location.last.id)
        post :sell, params: { loader: 'asteroid.nickel_ore', type: 'item', quantity: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(Item.count).to eq(1)
      end

      it 'should sell item on price of item' do
        MarketListing.create(location: user.location, loader: 'asteroid.nickel_ore', listing_type: 'item', price: 1000, amount: 1)
        post :sell, params: { loader: 'asteroid.nickel_ore', type: 'item', quantity: 1 }
        expect(response).to have_http_status(:ok)
        expect(user.reload.units).to eq(18)
        expect(Item.count).to eq(0)
      end

      it 'should sell not more items than user has' do
        post :sell, params: { loader: 'asteroid.nickel_ore', type: 'item', quantity: '2' }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(Item.count).to eq(1)
      end

      it 'should sell ship' do
        post :sell, params: { loader: ship.name, id: ship.id, type: :ship, quantity: 1 }
        expect(response).to have_http_status(:ok)
        expect(user.reload.units).to eq(10)
        expect(Spaceship.count).to eq(1)
      end

      it 'should not sell ship if selling more' do
        post :sell, params: { loader: ship.name, id: ship.id, type: :ship, quantity: '2' }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(Spaceship.count).to eq(2)
      end

      it 'should not sell ship which is not here' do
        ship.update(location_id: Location.last.id)
        post :sell, params: { loader: ship.name, id: ship.id, type: :ship, quantity: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(Spaceship.count).to eq(2)
      end

      it 'should not sell active spaceship but may sell other ship' do
        post :sell, params: { loader: user.active_spaceship.name, id: user.active_spaceship.id, type: :ship, quantity: 1 }
        expect(response).to have_http_status(:ok)
        expect(user.reload.units).to eq(10)
        expect(Spaceship.count).to eq(1)
      end

      it 'should not sell shit' do
        post :sell, params: { loader: 'Blub', type: :ship, quantity: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(Spaceship.count).to eq(2)
      end
    end

    describe 'POST delete_listing' do
      it 'should remove buy order' do
        listing = MarketListing.create(order_type: :buy, user: user, listing_type: :ship,
                                       loader: 'Nano', amount: 2, price: 100, location: user.location)

        post :delete_listing, params: { id: listing.id }
        expect(response).to have_http_status(:ok)
        expect(user.reload.units).to eq(210)
        expect(user.location.spaceships.count).to eq(0)
      end

      it 'should remove sell order' do
        listing = MarketListing.create(order_type: :sell, user: user, listing_type: :ship,
                                       loader: 'Nano', amount: 2, price: 100, location: user.location)

        post :delete_listing, params: { id: listing.id }
        expect(response).to have_http_status(:ok)
        expect(user.reload.units).to eq(10)
        expect(user.location.spaceships.count).to eq(2)
      end

      it 'should not be able to remove another players listing' do
        user2 = create(:user_with_faction)
        listing = MarketListing.create(order_type: :sell, user: user2, listing_type: :ship,
                                       loader: 'Nano', amount: 2, price: 100, location: user.location)

        post :delete_listing, params: { id: listing.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(user.location.spaceships.count).to eq(0)
      end

      it 'should not be able to delete listing while in space' do
        user.update(docked: false)
        listing = MarketListing.create(order_type: :sell, user: user, listing_type: :ship,
                                       loader: 'Nano', amount: 2, price: 100, location: user.location)

        post :delete_listing, params: { id: listing.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(user.location.spaceships.count).to eq(0)
      end

      it 'should not be able to delete listing while docked at another station' do
        listing = MarketListing.create(order_type: :sell, user: user, listing_type: :ship,
                                       loader: 'Nano', amount: 2, price: 100, location: Location.station.last)

        post :delete_listing, params: { id: listing.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.units).to eq(10)
        expect(user.location.spaceships.count).to eq(0)
      end
    end
  end
end
