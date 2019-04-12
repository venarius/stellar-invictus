# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnemyWorker, type: :worker do
  #   def perform(npc_id, location_id, target_id = nil, attack = nil, count = nil, hard = nil)

  it 'sanity check in asteroid field' do
    user = create :user_with_faction, location: Location.asteroid_field.first, docked: false

    Sidekiq::Testing.inline! do
      subject.perform(nil, user.location)
    end
  end

  it 'sanity check in exploration_site with HARD' do
    user = create :user_with_faction, location: create(:location, location_type: :exploration_site), docked: false

    Sidekiq::Testing.inline! do
      subject.perform(nil, user.location, nil, nil, nil, true)
    end
  end

  it 'sanity check in worm_hole' do
    user = create :user_with_faction, location: create(:location, system: create(:system, security_status: :wormhole)), docked: false

    Sidekiq::Testing.inline! do
      subject.perform(nil, user.location)
    end
  end

end
