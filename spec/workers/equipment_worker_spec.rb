# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EquipmentWorker, type: :worker do
  #  perform(player_id)
  it 'should perform a sanity check with no equipment' do
    user = create :user_with_faction

    subject.perform(user)
    user.reload

    assert_broadcast_method(user.channel_id, 'disable_equipment')
    expect(user.equipment_worker).to eq(false)
  end

  it 'should perform a sanity check WITH equipment' do
    user = create :user_with_faction
    user.ship.update(name: 'Atlas')
    create(:item, loader: 'equipment.weapons.military_laser', spaceship: user.ship, equipped: true, active: true)
    enemy = create :npc, npc_type: :enemy, target: user, location: user.location, hp: 50
    user.update(npc_target: enemy)

    expect {
      Sidekiq::Testing.inline! do
        subject.perform(user)
      end
    }.to change(Npc, :count).by(-1)
    user.reload

    assert_broadcast_method(user.channel_id, 'disable_equipment')
    expect(user.equipment_worker).to eq(false)
  end

end
