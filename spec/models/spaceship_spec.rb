require 'rails_helper'

describe Spaceship do
  context 'new spaceship' do
    describe 'attributes' do
      it { should respond_to :user }
      it { should respond_to :name }
      it { should respond_to :warp_target_id }
      it { should respond_to :warp_scrambled }
      it { should respond_to :location }
      it { should respond_to :insured }
    end

    describe 'Functions' do
      let(:user) { create :user_with_faction }
      let(:ship) { create :spaceship, user: user }

      describe 'get_attribute' do
        it 'should return attribute of spaceship from yml' do
          expect(ship.get_attribute('storage')).to eq(10)
        end

        it 'should return attribute of spaceship from yml when nil' do
          expect(ship.get_attribute('noot')).to eq(nil)
        end

        it 'should return nil if nil given' do
          expect(ship.get_attribute()).to eq(nil)
        end
      end

      describe 'get_items' do
        it 'should return items in storage of ship' do
          create :item, loader: "test", spaceship: ship, count: 2
          expect(ship.get_items.first.count).to eq(2)
        end
      end

      describe 'drop_loot' do
        it 'should not create structure when no items' do
          expect {
            ship.drop_loot
          }.to change { Structure.count }.by(0)
        end

        it 'should create structure with items when ship has items in it' do
          create_list :item, 2, loader: 'test', spaceship: ship

          expect {
            ship.drop_loot
          }.to change { Structure.count }.by(1)
          expect(Structure.first.get_items.count).to be >= 0
        end
      end
    end
  end
end
