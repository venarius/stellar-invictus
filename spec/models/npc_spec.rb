# == Schema Information
#
# Table name: npcs
#
#  id          :bigint(8)        not null, primary key
#  hp          :integer
#  name        :string
#  npc_state   :integer
#  npc_type    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :bigint(8)
#  target_id   :integer
#
# Indexes
#
#  index_npcs_on_location_id  (location_id)
#  index_npcs_on_npc_type     (npc_type)
#  index_npcs_on_target_id    (target_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#

require 'rails_helper'

describe Npc do
  context 'new npc' do
    describe 'attributes' do
      it { should respond_to :location }
      it { should respond_to :npc_type }
      it { should respond_to :target }
      it { should respond_to :hp }
      it { should respond_to :name }
    end

    describe 'Enums' do
      it { should define_enum_for(:npc_type).with_values([:enemy, :police, :politician, :bodyguard, :wanted_enemy]) }
      it { should define_enum_for(:npc_state).with_values([:created, :targeting, :attacking, :waiting]) }
    end

    describe 'Functions' do
      before(:each) do
        @npc = create(:npc, location: Location.first)
      end

      describe 'die' do
        it 'should spawn NpcDieWorker' do
          @npc.die
          expect(NpcDiedWorker.jobs.size).to eq(1)
        end
      end

      describe 'drop_loot' do
        it 'should create structure and put random loot in it' do
          @npc.drop_loot
          expect(Structure.count).to eq(2)
          expect(Structure.last.get_items.count).to be > 0
        end
      end

      describe 'remove_being_targeted' do
        it 'should remove npc as target from others' do
          user = create(:user_with_faction, npc_target_id: @npc.id)
          @npc.remove_being_targeted
          expect(user.reload.npc_target).to eq(nil)
        end
      end

      describe 'give_bounty' do
        it 'should give user random bounty' do
          user = create(:user_with_faction)
          @npc.give_bounty(user)
          expect(user.reload.units).not_to eq(10)
        end
      end
    end
  end
end
