# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MissionWorker, type: :worker do
  #   def perform(location_id, amount = 0, rounds = 0, wave_amount = 0)

  it 'sanity check in asteroid field' do
    user = create :user_with_faction, location: Location.asteroid_field.first, docked: false
    mission = MissionGenerator.generate_mission(user.location)
    expect(mission).to be_present
    mission.update(user: user)
    user.location.mission = mission

    Sidekiq::Testing.inline! do
      subject.perform(user.location, 1, 1, 1)
    end
  end

end
