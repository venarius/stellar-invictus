# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

run Rails.application

# ##############################
#            CUSTOM
# ##############################

require "#{Rails.root.to_s}/config/initializers/variables.rb"

# User
User.all.each do |user|
   user.update_columns(online: 0, in_warp: false, target_id: nil, mining_target_id: nil, npc_target_id: nil, is_attacking: false, equipment_worker: false, logout_timer: false)
   user.update_columns(docked: false) if user.docked.nil?
end

# NPC
Npc.destroy_all

# Cargocontainer
Structure.where(structure_type: 'container').where("created_at > ?", 1.day.ago).destroy_all
# Wrecks
Structure.where(structure_type: 'wreck').where("created_at > ?", 1.day.ago).destroy_all

# Ships
Spaceship.all.each do |ship|
  ship.update_columns(warp_scrambled: false, warp_target_id: nil, hp: SHIP_VARIABLES[ship.name]['hp'])
end

# Items
Item.all.each do |item|
  item.update_columns(active: false)
end

# Mission Scunk
Location.where(location_type: 'mission', mission: nil).destroy_all