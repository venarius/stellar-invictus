if ActiveRecord::Base.connection.table_exists? 'users'
  User.all.each do |user|
     user.update_columns(online: false) 
  end
end