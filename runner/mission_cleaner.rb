Mission.where(mission_status: :offered).each do |mission|
  if mission.mission_location
    next unless mission.mission_location.users.empty? && Spaceship.where(warp_target_id: mission.mission_location.id).empty?
  end

  Item.where(mission_id: mission.id).destroy_all
  mission.destroy
end
