require 'rails_helper'

describe Item do
  context 'new item' do
    describe 'attributes' do
      it { should respond_to :loader }
      it { should respond_to :user }
      it { should respond_to :spaceship }
      it { should respond_to :location }
      it { should respond_to :structure }
      it { should respond_to :equipped }
    end

    describe 'Functions' do
      describe 'get_attribute' do
        it 'should return attribute of item' do
          expect(Item.get_attribute('test', :weight)).to eq(1)
        end

        it 'should return nil attribute of item' do
          expect(Item.get_attribute('hudaf', :weight)).to eq(nil)
        end

        it 'should return default if attribute not defined' do
          expect(Item.get_attribute('hudaf', 'weight', default: 10)).to eq(10)
        end

        it 'should return attribute of item' do
          item = Item.new(loader: 'asteroid.iron_ore', user: FactoryBot.create(:user_with_faction))
          expect(item.get_attribute('weight')).to eq(1)
        end
      end

      describe 'remove from user' do
        let(:user) { create :user_with_faction }
        let!(:item) { create :item, loader: 'asteroid.iron_ore', user: user, location: user.location }

        it 'should remove item from users location' do
          expect {
            Item.remove_from_user(user: user, location: user.location, loader: item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(-1)
        end

        it 'should remove item from users ship' do
          item.update_columns(location_id: nil, spaceship_id: user.active_spaceship.id)
          expect {
            Item.remove_from_user(user: user, loader: item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(-1)
        end

        it 'should remove item from counter if less than item amount' do
          item.update_columns(count: 2)
          expect {
            Item.remove_from_user(user: user, loader: item.loader, location: user.location, amount: 1)
          }.to change {
            Item.count
          }.by(0)
        end
      end

      describe 'move_to_station' do
        before(:each) do
          @user = FactoryBot.create(:user_with_faction)
          @item = Item.create(loader: 'asteroid.iron_ore', spaceship: @user.active_spaceship)
        end

        it 'should move to station and place' do
          expect {
            Item.store_in_station(user: @user, loader: @item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(0)
        end

        it 'should move to station and stack' do
          Item.create(loader: "asteroid.iron_ore", location: @user.location, user: @user)
          expect {
            Item.store_in_station(user: @user, loader: @item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(-1)
          expect(Item.where(location: @user.location, user: @user).count).to eq(1)
          expect(Item.where(location: @user.location, user: @user).first.count).to eq(2)
        end

        it 'should move to station and remove from counter of original if amount less than count' do
          @item.update_columns(count: 2)
          expect {
            Item.store_in_station(user: @user, loader: @item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(1)
          expect(@item.reload.count).to eq(1)
        end
      end

      describe 'store_in_ship' do
        before(:each) do
          @user = FactoryBot.create(:user_with_faction)
          @item = Item.create(loader: 'asteroid.iron_ore', location: @user.location, user: @user)
        end

        it 'should move to ship and place' do
          expect {
            Item.store_in_ship(user: @user, loader: @item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(0)
        end

        it 'should move to ship and stack' do
          Item.create(loader: "asteroid.iron_ore", spaceship: @user.active_spaceship)
          expect {
            Item.store_in_ship(user: @user, loader: @item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(-1)
          expect(Item.where(spaceship: @user.active_spaceship).count).to eq(1)
          expect(Item.where(spaceship: @user.active_spaceship).first.count).to eq(2)
        end

        it 'should move to ship and remove from counter of original if amount less than count' do
          @item.update_columns(count: 2)
          expect {
            Item.store_in_ship(user: @user, loader: @item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(1)
          expect(@item.reload.count).to eq(1)
        end
      end

      describe 'equipment_medium' do
        it 'should return array of medium items' do
          expect(Item.equipment_medium.class).to eq(Array)
        end
      end

      describe 'equipment_hard' do
        it 'should return array of hard items' do
          expect(Item.equipment_hard.class).to eq(Array)
        end
      end

      describe 'items' do
        it 'should return array of items' do
          expect(Item.items.class).to eq(Array)
        end
      end

    end
  end
end
