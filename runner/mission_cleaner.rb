Mission.where(mission_status: :offered).each do |mission|
  if mission.mission_location
    next unless mission.mission_location.users.empty? and Spaceship.where(warp_target_id: mission.mission_location.id).empty?
  end
  
  mission.destroy
end