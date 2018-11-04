if ActiveRecord::Base.connection.table_exists? 'users'
  User.all.each do |user|
     user.update_columns(online: 0, in_warp: false#, target_id: nil)
     #user.update_columns(docked: false) if user.docked.nil?
  end
end