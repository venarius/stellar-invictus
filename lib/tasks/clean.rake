namespace :clean do

  desc "Clear old Chat Messages"
  task chat_messages: :environment do
    ChatRoom.all.each do |room|
      if room.chat_messages.count > 20
        room.chat_messages.order('created_at ASC').limit(room.chat_messages.count - 20).destroy_all
      end
    end
  end

  desc "Remove unwanted people from corp chats"
  task corporation_chats: :environment do
    User.where(corporation_role: :founder).each do |user|
      room = user.corporation.chat_room
      room.users.each do |u|
        room.users.destroy(u) if u.corporation_id != user.corporation_id
      end
    end
  end

  desc "Clean after restart of Server"
  task restart: :environment do
    # User
    User.update_all(online: 0, in_warp: false, target_id: nil, mining_target_id: nil, npc_target_id: nil, is_attacking: false, equipment_worker: false, logout_timer: false)

    # NPC
    Npc.destroy_all

    # Cargocontainer
    Structure.where(structure_type: 'container').where("created_at > ?", 1.day.ago).destroy_all
    # Wrecks
    Structure.where(structure_type: 'wreck').where("created_at > ?", 1.day.ago).destroy_all

    # Ships
    Spaceship.where(warp_scrambled: true).update_all(warp_scrambled: false, warp_target_id: nil)

    # Items
    Item.where(active: true).update_all(active: false)

    # Mission Scunk
    Location.where(location_type: 'mission', mission: nil).destroy_all

    # Lore
    Npc.create(name: "Zonia Lowe", hp: 1000000, location: System.find_by(name: "Finid").locations.where(location_type: :asteroid_field).first, npc_type: :enemy)
  end

end
