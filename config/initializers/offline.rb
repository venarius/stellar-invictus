User.all.each do |user|
   user.update_columns(online: false) 
end