# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

run Rails.application

# ##############################
#            CUSTOM
# ##############################

require "#{Rails.root.to_s}/config/initializers/variables.rb"

# User
User.update_all(online: 0, in_warp: false, target_id: nil, mining_target_id: nil, npc_target_id: nil, is_attacking: false, equipment_worker: false, logout_timer: false)

# NPC
Npc.destroy_all

# Cargocontainer
Structure.where(structure_type: 'container').where("created_at > ?", 1.day.ago).destroy_all
# Wrecks
Structure.where(structure_type: 'wreck').where("created_at > ?", 1.day.ago).destroy_all

# Ships
Spaceship.update_all(warp_scrambled: false, warp_target_id: nil)

# Items
Item.update_all(active: false)

# Mission Scunk
Location.where(location_type: 'mission', mission: nil).destroy_all

# Lore
Npc.create(name: "Zonia Lowe", hp: 1000000, location: System.find_by(name: "Finid").locations.where(location_type: :asteroid_field).first, npc_type: :enemy)

# Corp Chat Room Cleaner
User.where(corporation_role: :founder).each do |user|
    room = user.corporation.chat_room
    room.users.each do |u|
        room.users.destroy(u) if u.corporation_id != user.corporation_id
    end
end