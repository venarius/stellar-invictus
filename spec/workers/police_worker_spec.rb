# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PoliceWorker, type: :worker do
  #   def perform(player_id, seconds, police_id = nil, idle = false, done = false)

  it 'should do nothing with bad info' do
    expect {
      subject.perform(nil)
    }.not_to change(PoliceWorker.jobs, :size)
  end

  it 'should create police if none provided' do
    user = create :user_with_faction
    expect {
      subject.perform(user)
    }.to change(Npc.police, :size).by(1)
  end

  it 'player should die' do
    user = create :user_with_faction
    old_location = user.location
    Sidekiq::Testing.inline! do
      subject.perform(user)
    end

    # Hard to tell if user has died, so, checking location -- which should be different
    assert_broadcast_method(old_location.channel_id, 'player_warp_out')
    user.reload
    expect(user.location.id).not_to eq(old_location.id)
  end

end
