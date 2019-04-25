# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NpcDiedWorker, type: :worker do
  let(:npc) { create :npc, location: Location.first }
  let(:user) { create :user_with_faction, npc_target: npc, location: npc.location }

  it 'should create loot' do
    expect {
      NpcDiedWorker.new.perform(npc.id)
    }.to change(Structure, :count).by(1)
    expect(Structure.last.items.count).to be > 0
  end

  it 'should de-target users who are targeting this npc' do
    user
    NpcDiedWorker.new.perform(npc.id)
    expect(user.reload.npc_target).to eq(nil)
  end

  it 'should do nothing with a bad id' do
    expect {
      NpcDiedWorker.new.perform(-1)
    }.not_to change(Structure, :count)
  end

  it 'should decrement mission enemy count' do
    location = create :location, location_type: :mission
    npc.update(location: location)
    user.update(location: location)
    mission = create :mission, location: location, user: user, enemy_amount: 2
    location.update(mission: mission)
    expect {
      NpcDiedWorker.new.perform(npc.id)
      mission.reload
    }.to change(mission, :enemy_amount).by(-1)
  end

end
