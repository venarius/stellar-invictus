namespace :clean do
  
  desc "Clear old Chat Messages"
  task :chat_messages => :environment do
    ChatRoom.all.each do |room|
      if room.chat_messages.count > 20
        room.chat_messages.order('created_at ASC').limit(room.chat_messages.count - 20).destroy_all
      end
    end
  end
end