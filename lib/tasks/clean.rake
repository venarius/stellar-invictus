namespace :clean do
  
  desc "Clear old Chat Messages"
  task :chat_messages => :environment do
    ChatRoom.all.each do |room|
      if room.chat_messages.count > 20
        room.chat_messages.order('created_at ASC').limit(room.chat_messages.count - 20).destroy_all
      end
    end
  end
  
  desc "Remove unwanted people from corp chats"
  task :corporation_chats => :environment do
    User.where(corporation_role: :founder).each do |user|
      room = user.corporation.chat_room
      room.users.each do |u|
          room.users.destroy(u) if u.corporation_id != user.corporation_id
      end
    end
  end
  
end