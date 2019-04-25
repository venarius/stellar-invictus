# == Schema Information
#
# Table name: items
#
#  id           :bigint(8)        not null, primary key
#  active       :boolean          default(FALSE)
#  count        :integer          default(1)
#  equipped     :boolean          default(FALSE)
#  loader       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  location_id  :bigint(8)
#  mission_id   :bigint(8)
#  spaceship_id :bigint(8)
#  structure_id :integer
#  user_id      :bigint(8)
#
# Indexes
#
#  index_items_on_loader        (loader)
#  index_items_on_location_id   (location_id)
#  index_items_on_mission_id    (mission_id)
#  index_items_on_spaceship_id  (spaceship_id)
#  index_items_on_structure_id  (structure_id)
#  index_items_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (mission_id => missions.id)
#  fk_rails_...  (spaceship_id => spaceships.id)
#  fk_rails_...  (user_id => users.id)
#

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
          item = Item.new(loader: 'asteroid.iron_ore', user: create(:user_with_faction))
          expect(item.get_attribute('weight')).to eq(1)
        end
      end

      describe 'remove from user' do
        let(:user) { create :user_with_faction }
        let!(:item) { create :item, loader: 'asteroid.iron_ore', user: user, location: user.location }

        it 'should remove item from users location' do
          expect {
            Item::RemoveFromUser.(user: user, location: user.location, loader: item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(-1)
        end

        it 'should remove item from users ship' do
          item.update(location_id: nil, spaceship_id: user.active_spaceship.id)
          expect {
            Item::RemoveFromUser.(user: user, loader: item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(-1)
        end

        it 'should remove item from counter if less than item amount' do
          item.update(count: 2)
          expect {
            Item::RemoveFromUser.(user: user, loader: item.loader, location: user.location, amount: 1)
          }.to change {
            Item.count
          }.by(0)
        end
      end

      describe 'move_to_station' do
        before(:each) do
          @user = create(:user_with_faction)
          @item = Item.create(loader: 'asteroid.iron_ore', spaceship: @user.active_spaceship)
        end

        it 'should move to station and place' do
          expect {
            Item::GiveToStation.(user: @user, loader: @item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(0)
        end

        it 'should move to station and stack' do
          Item.create(loader: 'asteroid.iron_ore', location: @user.location, user: @user)
          expect {
            Item::GiveToStation.(user: @user, loader: @item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(-1)
          expect(Item.where(location: @user.location, user: @user).count).to eq(1)
          expect(Item.where(location: @user.location, user: @user).first.count).to eq(2)
        end

        it 'should move to station and remove from counter of original if amount less than count' do
          @item.update(count: 2)
          expect {
            Item::GiveToStation.(user: @user, loader: @item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(1)
          expect(@item.reload.count).to eq(1)
        end
      end

      describe 'store_in_ship' do
        before(:each) do
          @user = create(:user_with_faction)
          @item = Item.create(loader: 'asteroid.iron_ore', location: @user.location, user: @user)
        end

        it 'should move to ship and place' do
          expect {
            Item::GiveToShip.(user: @user, loader: @item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(0)
        end

        it 'should move to ship and stack' do
          Item.create(loader: 'asteroid.iron_ore', spaceship: @user.active_spaceship)
          expect {
            Item::GiveToShip.(user: @user, loader: @item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(-1)
          expect(Item.where(spaceship: @user.active_spaceship).count).to eq(1)
          expect(Item.where(spaceship: @user.active_spaceship).first.count).to eq(2)
        end

        it 'should move to ship and remove from counter of original if amount less than count' do
          @item.update(count: 2)
          expect {
            Item::GiveToShip.(user: @user, loader: @item.loader, amount: 1)
          }.to change {
            Item.count
          }.by(1)
          expect(@item.reload.count).to eq(1)
        end
      end

      describe 'asteroids' do
        it 'should return array of asteroids' do
          expect(Item::ASTEROIDS).to be_an(Array)
          Item::ASTEROIDS.each do |loader|
            expect(Item.get_attribute(loader, :name)).to be_present, "Expected #{loader} to have a name"
          end
        end
      end

      describe 'materials' do
        it 'should return array of materials' do
          expect(Item::MATERIALS).to be_an(Array)
          Item::MATERIALS.each do |loader|
            expect(Item.get_attribute(loader, :name)).to be_present, "Expected #{loader} to have a name"
          end
        end
      end

       describe 'equipment_easy' do
         it 'should return array of easy items' do
           expect(Item::EQUIPMENT_EASY).to be_an(Array)
           Item::EQUIPMENT_EASY.each do |loader|
             expect(Item.get_attribute(loader, :name)).to be_present, "Expected #{loader} to have a name"
           end
         end
       end

      describe 'equipment_medium' do
        it 'should return array of medium items' do
          expect(Item::EQUIPMENT_MEDIUM).to be_an(Array)
          Item::EQUIPMENT_MEDIUM.each do |loader|
            expect(Item.get_attribute(loader, :name)).to be_present, "Expected #{loader} to have a name"
          end
        end
      end

      describe 'equipment_hard' do
        it 'should return array of hard items' do
          expect(Item::EQUIPMENT_HARD).to be_an(Array)
          Item::EQUIPMENT_HARD.each do |loader|
            expect(Item.get_attribute(loader, :name)).to be_present, "Expected #{loader} to have a name"
          end
        end
      end

      describe 'equipment_xtra' do
        it 'should return array of xtra items' do
          expect(Item::EQUIPMENT_XTRA).to be_an(Array)
          Item::EQUIPMENT_XTRA.each do |loader|
            expect(Item.get_attribute(loader, :name)).to be_present, "Expected #{loader} to have a name"
          end
        end
      end

      describe 'items' do
        it 'should return array of items' do
          expect(Item::ITEMS).to be_an(Array)
        end
      end

    end
  end
end
