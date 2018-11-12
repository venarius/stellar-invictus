begin
  if ActiveRecord::Base.connection.table_exists? 'users'
    User.all.each do |user|
       user.update_columns(online: 0, in_warp: false, target_id: nil, mining_target_id: nil, npc_target_id: nil)
       user.update_columns(docked: false) if user.docked.nil?
    end
  end
  
  if ActiveRecord::Base.connection.table_exists? 'asteroids'
    Asteroid.all.each do |asteroid|
       asteroid.update_columns(resources: 35000)
    end
  end
  
  Npc.destroy_all
rescue StandardError
  true
end