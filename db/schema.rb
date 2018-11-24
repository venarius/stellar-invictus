# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_11_24_181315) do

  create_table "asteroids", force: :cascade do |t|
    t.integer "location_id"
    t.integer "asteroid_type"
    t.integer "resources"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_asteroids_on_location_id"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.integer "user_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chat_room_id"
    t.index ["chat_room_id"], name: "index_chat_messages_on_chat_room_id"
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
    t.index ["user_id"], name: "index_chat_messages_on_user_id_and_system_id_and_type"
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.string "title"
    t.integer "location_id"
    t.integer "chatroom_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "identifier"
    t.index ["location_id"], name: "index_chat_rooms_on_location_id"
  end

  create_table "chat_rooms_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "chat_room_id"
    t.index ["chat_room_id"], name: "index_chat_rooms_users_on_chat_room_id"
    t.index ["user_id"], name: "index_chat_rooms_users_on_user_id"
  end

  create_table "factions", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id"
    t.index ["location_id"], name: "index_factions_on_location_id"
  end

  create_table "fleets", force: :cascade do |t|
    t.integer "chat_room_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_fleets_on_chat_room_id"
    t.index ["user_id"], name: "index_fleets_on_user_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "friend_id"
    t.boolean "accepted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "game_mails", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "recipient_id"
    t.string "header"
    t.text "body"
    t.integer "units"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.integer "spaceship_id"
    t.string "loader"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "structure_id"
    t.boolean "equipped"
    t.boolean "active", default: false
    t.index ["location_id"], name: "index_items_on_location_id"
    t.index ["spaceship_id"], name: "index_items_on_spaceship_id"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "jumpgates", force: :cascade do |t|
    t.integer "origin_id"
    t.integer "destination_id"
    t.integer "traveltime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.integer "system_id"
    t.integer "location_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "faction_id"
    t.index ["faction_id"], name: "index_locations_on_faction_id"
    t.index ["system_id"], name: "index_locations_on_system_id"
  end

  create_table "npcs", force: :cascade do |t|
    t.integer "npc_type"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "target"
    t.string "name"
    t.integer "hp"
    t.index ["location_id"], name: "index_npcs_on_location_id"
  end

  create_table "spaceships", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.integer "hp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "warp_target"
    t.boolean "warp_scrambled", default: false
    t.integer "warp_target_id"
    t.index ["user_id"], name: "index_spaceships_on_user_id"
  end

  create_table "structures", force: :cascade do |t|
    t.integer "structure_type"
    t.integer "location_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_structures_on_location_id"
    t.index ["user_id"], name: "index_structures_on_user_id"
  end

  create_table "systems", force: :cascade do |t|
    t.string "name"
    t.integer "security_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "family_name"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "faction_id"
    t.integer "system_id"
    t.integer "online", default: 0
    t.string "avatar"
    t.integer "location_id"
    t.boolean "in_warp", default: false
    t.integer "units", default: 1000
    t.string "full_name"
    t.integer "active_spaceship_id"
    t.boolean "docked", default: false
    t.integer "target_id"
    t.integer "mining_target_id"
    t.integer "npc_target_id"
    t.boolean "is_attacking"
    t.datetime "last_action"
    t.text "bio"
    t.integer "fleet_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["faction_id"], name: "index_users_on_faction_id"
    t.index ["fleet_id"], name: "index_users_on_fleet_id"
    t.index ["location_id"], name: "index_users_on_location_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["system_id"], name: "index_users_on_system_id"
  end

end
