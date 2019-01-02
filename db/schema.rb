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

ActiveRecord::Schema.define(version: 2019_01_02_211336) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "asteroids", force: :cascade do |t|
    t.bigint "location_id"
    t.integer "asteroid_type"
    t.integer "resources"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_asteroids_on_location_id"
  end

  create_table "blueprints", force: :cascade do |t|
    t.string "loader"
    t.float "efficiency", default: 1.5
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_blueprints_on_user_id"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.bigint "user_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "chat_room_id"
    t.index ["chat_room_id"], name: "index_chat_messages_on_chat_room_id"
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.string "title"
    t.bigint "location_id"
    t.integer "chatroom_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "identifier"
    t.index ["location_id"], name: "index_chat_rooms_on_location_id"
  end

  create_table "chat_rooms_users", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "chat_room_id"
    t.index ["chat_room_id"], name: "index_chat_rooms_users_on_chat_room_id"
    t.index ["user_id"], name: "index_chat_rooms_users_on_user_id"
  end

  create_table "corp_applications", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "corporation_id"
    t.text "application_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["corporation_id"], name: "index_corp_applications_on_corporation_id"
    t.index ["user_id"], name: "index_corp_applications_on_user_id"
  end

  create_table "corporations", force: :cascade do |t|
    t.string "name"
    t.string "ticker"
    t.text "bio"
    t.text "motd"
    t.integer "units", default: 0
    t.float "tax", default: 0.0
    t.bigint "chat_room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_corporations_on_chat_room_id"
  end

  create_table "craft_jobs", force: :cascade do |t|
    t.datetime "completion"
    t.string "loader"
    t.bigint "user_id"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_craft_jobs_on_location_id"
    t.index ["user_id"], name: "index_craft_jobs_on_user_id"
  end

  create_table "factions", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "location_id"
    t.index ["location_id"], name: "index_factions_on_location_id"
  end

  create_table "finance_histories", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "corporation_id"
    t.integer "amount"
    t.integer "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["corporation_id"], name: "index_finance_histories_on_corporation_id"
    t.index ["user_id"], name: "index_finance_histories_on_user_id"
  end

  create_table "fleets", force: :cascade do |t|
    t.bigint "chat_room_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_fleets_on_chat_room_id"
    t.index ["user_id"], name: "index_fleets_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
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
    t.boolean "read", default: false
  end

  create_table "items", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "location_id"
    t.bigint "spaceship_id"
    t.string "loader"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "structure_id"
    t.boolean "equipped", default: false
    t.boolean "active", default: false
    t.bigint "mission_id"
    t.index ["location_id"], name: "index_items_on_location_id"
    t.index ["mission_id"], name: "index_items_on_mission_id"
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
    t.bigint "system_id"
    t.integer "location_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "faction_id"
    t.bigint "mission_id"
    t.boolean "hidden", default: false
    t.integer "enemy_amount", default: 0
    t.integer "station_type"
    t.index ["faction_id"], name: "index_locations_on_faction_id"
    t.index ["mission_id"], name: "index_locations_on_mission_id"
    t.index ["system_id"], name: "index_locations_on_system_id"
  end

  create_table "market_listings", force: :cascade do |t|
    t.string "loader"
    t.integer "listing_type"
    t.integer "price"
    t.integer "amount"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_market_listings_on_location_id"
  end

  create_table "missions", force: :cascade do |t|
    t.integer "mission_type"
    t.integer "mission_status"
    t.string "agent_name"
    t.string "agent_avatar"
    t.integer "text"
    t.integer "reward"
    t.integer "deliver_to"
    t.integer "mission_location_id"
    t.bigint "faction_id"
    t.bigint "user_id"
    t.bigint "location_id"
    t.integer "difficulty"
    t.integer "enemy_amount"
    t.string "mission_loader"
    t.integer "mission_amount"
    t.float "faction_bonus"
    t.float "faction_malus"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faction_id"], name: "index_missions_on_faction_id"
    t.index ["location_id"], name: "index_missions_on_location_id"
    t.index ["user_id"], name: "index_missions_on_user_id"
  end

  create_table "npcs", force: :cascade do |t|
    t.integer "npc_type"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "target"
    t.string "name"
    t.integer "hp"
    t.integer "npc_state"
    t.index ["location_id"], name: "index_npcs_on_location_id"
  end

  create_table "spaceships", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.integer "hp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "warp_scrambled", default: false
    t.integer "warp_target_id"
    t.bigint "location_id"
    t.index ["location_id"], name: "index_spaceships_on_location_id"
    t.index ["user_id"], name: "index_spaceships_on_user_id"
  end

  create_table "structures", force: :cascade do |t|
    t.integer "structure_type"
    t.bigint "location_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "riddle"
    t.index ["location_id"], name: "index_structures_on_location_id"
    t.index ["user_id"], name: "index_structures_on_user_id"
  end

  create_table "systems", force: :cascade do |t|
    t.string "name"
    t.integer "security_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thredded_categories", force: :cascade do |t|
    t.bigint "messageboard_id", null: false
    t.text "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "slug", null: false
    t.index "lower(name) text_pattern_ops", name: "thredded_categories_name_ci"
    t.index ["messageboard_id", "slug"], name: "index_thredded_categories_on_messageboard_id_and_slug", unique: true
    t.index ["messageboard_id"], name: "index_thredded_categories_on_messageboard_id"
  end

  create_table "thredded_messageboard_groups", force: :cascade do |t|
    t.string "name"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thredded_messageboard_notifications_for_followed_topics", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "messageboard_id", null: false
    t.string "notifier_key", limit: 90, null: false
    t.boolean "enabled", default: true, null: false
    t.index ["user_id", "messageboard_id", "notifier_key"], name: "thredded_messageboard_notifications_for_followed_topics_unique", unique: true
  end

  create_table "thredded_messageboard_users", force: :cascade do |t|
    t.bigint "thredded_user_detail_id", null: false
    t.bigint "thredded_messageboard_id", null: false
    t.datetime "last_seen_at", null: false
    t.index ["thredded_messageboard_id", "last_seen_at"], name: "index_thredded_messageboard_users_for_recently_active"
    t.index ["thredded_messageboard_id", "thredded_user_detail_id"], name: "index_thredded_messageboard_users_primary", unique: true
  end

  create_table "thredded_messageboards", force: :cascade do |t|
    t.text "name", null: false
    t.text "slug"
    t.text "description"
    t.integer "topics_count", default: 0
    t.integer "posts_count", default: 0
    t.integer "position", null: false
    t.bigint "last_topic_id"
    t.bigint "messageboard_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "locked", default: false, null: false
    t.index ["messageboard_group_id"], name: "index_thredded_messageboards_on_messageboard_group_id"
    t.index ["slug"], name: "index_thredded_messageboards_on_slug", unique: true
  end

  create_table "thredded_notifications_for_followed_topics", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notifier_key", limit: 90, null: false
    t.boolean "enabled", default: true, null: false
    t.index ["user_id", "notifier_key"], name: "thredded_notifications_for_followed_topics_unique", unique: true
  end

  create_table "thredded_notifications_for_private_topics", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notifier_key", limit: 90, null: false
    t.boolean "enabled", default: true, null: false
    t.index ["user_id", "notifier_key"], name: "thredded_notifications_for_private_topics_unique", unique: true
  end

  create_table "thredded_post_moderation_records", force: :cascade do |t|
    t.bigint "post_id"
    t.bigint "messageboard_id"
    t.text "post_content"
    t.bigint "post_user_id"
    t.text "post_user_name"
    t.bigint "moderator_id"
    t.integer "moderation_state", null: false
    t.integer "previous_moderation_state", null: false
    t.datetime "created_at", null: false
    t.index ["messageboard_id", "created_at"], name: "index_thredded_moderation_records_for_display", order: { created_at: :desc }
  end

  create_table "thredded_posts", force: :cascade do |t|
    t.bigint "user_id"
    t.text "content"
    t.string "source", limit: 191, default: "web"
    t.bigint "postable_id", null: false
    t.bigint "messageboard_id", null: false
    t.integer "moderation_state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, content)", name: "thredded_posts_content_fts", using: :gist
    t.index ["messageboard_id"], name: "index_thredded_posts_on_messageboard_id"
    t.index ["moderation_state", "updated_at"], name: "index_thredded_posts_for_display"
    t.index ["postable_id", "created_at"], name: "index_thredded_posts_on_postable_id_and_created_at"
    t.index ["postable_id"], name: "index_thredded_posts_on_postable_id"
    t.index ["user_id"], name: "index_thredded_posts_on_user_id"
  end

  create_table "thredded_private_posts", force: :cascade do |t|
    t.bigint "user_id"
    t.text "content"
    t.bigint "postable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["postable_id", "created_at"], name: "index_thredded_private_posts_on_postable_id_and_created_at"
  end

  create_table "thredded_private_topics", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "last_user_id"
    t.text "title", null: false
    t.text "slug", null: false
    t.integer "posts_count", default: 0
    t.string "hash_id", limit: 20, null: false
    t.datetime "last_post_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hash_id"], name: "index_thredded_private_topics_on_hash_id"
    t.index ["last_post_at"], name: "index_thredded_private_topics_on_last_post_at"
    t.index ["slug"], name: "index_thredded_private_topics_on_slug", unique: true
  end

  create_table "thredded_private_users", force: :cascade do |t|
    t.bigint "private_topic_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["private_topic_id"], name: "index_thredded_private_users_on_private_topic_id"
    t.index ["user_id"], name: "index_thredded_private_users_on_user_id"
  end

  create_table "thredded_topic_categories", force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.bigint "category_id", null: false
    t.index ["category_id"], name: "index_thredded_topic_categories_on_category_id"
    t.index ["topic_id"], name: "index_thredded_topic_categories_on_topic_id"
  end

  create_table "thredded_topics", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "last_user_id"
    t.text "title", null: false
    t.text "slug", null: false
    t.bigint "messageboard_id", null: false
    t.integer "posts_count", default: 0, null: false
    t.boolean "sticky", default: false, null: false
    t.boolean "locked", default: false, null: false
    t.string "hash_id", limit: 20, null: false
    t.integer "moderation_state", null: false
    t.datetime "last_post_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, title)", name: "thredded_topics_title_fts", using: :gist
    t.index ["hash_id"], name: "index_thredded_topics_on_hash_id"
    t.index ["last_post_at"], name: "index_thredded_topics_on_last_post_at"
    t.index ["messageboard_id"], name: "index_thredded_topics_on_messageboard_id"
    t.index ["moderation_state", "sticky", "updated_at"], name: "index_thredded_topics_for_display", order: { sticky: :desc, updated_at: :desc }
    t.index ["slug"], name: "index_thredded_topics_on_slug", unique: true
    t.index ["user_id"], name: "index_thredded_topics_on_user_id"
  end

  create_table "thredded_user_details", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "latest_activity_at"
    t.integer "posts_count", default: 0
    t.integer "topics_count", default: 0
    t.datetime "last_seen_at"
    t.integer "moderation_state", default: 0, null: false
    t.datetime "moderation_state_changed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latest_activity_at"], name: "index_thredded_user_details_on_latest_activity_at"
    t.index ["moderation_state", "moderation_state_changed_at"], name: "index_thredded_user_details_for_moderations", order: { moderation_state_changed_at: :desc }
    t.index ["user_id"], name: "index_thredded_user_details_on_user_id", unique: true
  end

  create_table "thredded_user_messageboard_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "messageboard_id", null: false
    t.boolean "follow_topics_on_mention", default: true, null: false
    t.boolean "auto_follow_topics", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "messageboard_id"], name: "thredded_user_messageboard_preferences_user_id_messageboard_id", unique: true
  end

  create_table "thredded_user_post_notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.datetime "notified_at", null: false
    t.index ["post_id"], name: "index_thredded_user_post_notifications_on_post_id"
    t.index ["user_id", "post_id"], name: "index_thredded_user_post_notifications_on_user_id_and_post_id", unique: true
  end

  create_table "thredded_user_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "follow_topics_on_mention", default: true, null: false
    t.boolean "auto_follow_topics", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_thredded_user_preferences_on_user_id", unique: true
  end

  create_table "thredded_user_private_topic_read_states", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "postable_id", null: false
    t.integer "unread_posts_count", default: 0, null: false
    t.integer "read_posts_count", default: 0, null: false
    t.integer "integer", default: 0, null: false
    t.datetime "read_at", null: false
    t.index ["user_id", "postable_id"], name: "thredded_user_private_topic_read_states_user_postable", unique: true
  end

  create_table "thredded_user_topic_follows", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "topic_id", null: false
    t.datetime "created_at", null: false
    t.integer "reason", limit: 2
    t.index ["user_id", "topic_id"], name: "thredded_user_topic_follows_user_topic", unique: true
  end

  create_table "thredded_user_topic_read_states", force: :cascade do |t|
    t.bigint "messageboard_id", null: false
    t.bigint "user_id", null: false
    t.bigint "postable_id", null: false
    t.integer "unread_posts_count", default: 0, null: false
    t.integer "read_posts_count", default: 0, null: false
    t.integer "integer", default: 0, null: false
    t.datetime "read_at", null: false
    t.index ["messageboard_id"], name: "index_thredded_user_topic_read_states_on_messageboard_id"
    t.index ["user_id", "messageboard_id"], name: "thredded_user_topic_read_states_user_messageboard"
    t.index ["user_id", "postable_id"], name: "thredded_user_topic_read_states_user_postable", unique: true
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
    t.bigint "faction_id"
    t.bigint "system_id"
    t.integer "online", default: 0
    t.string "avatar"
    t.bigint "location_id"
    t.boolean "in_warp", default: false
    t.integer "units", default: 10
    t.string "full_name"
    t.integer "active_spaceship_id"
    t.boolean "docked", default: false
    t.integer "target_id"
    t.integer "mining_target_id"
    t.integer "npc_target_id"
    t.boolean "is_attacking"
    t.datetime "last_action"
    t.text "bio"
    t.bigint "fleet_id"
    t.integer "bounty", default: 0
    t.integer "bounty_claimed", default: 0
    t.string "route", default: [], array: true
    t.float "reputation_1", default: 0.0
    t.float "reputation_2", default: 0.0
    t.float "reputation_3", default: 0.0
    t.bigint "corporation_id"
    t.integer "corporation_role", default: 0
    t.boolean "admin"
    t.index "lower((full_name)::text) text_pattern_ops", name: "users_full_name_lower", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["corporation_id"], name: "index_users_on_corporation_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["faction_id"], name: "index_users_on_faction_id"
    t.index ["fleet_id"], name: "index_users_on_fleet_id"
    t.index ["location_id"], name: "index_users_on_location_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["system_id"], name: "index_users_on_system_id"
  end

  add_foreign_key "asteroids", "locations"
  add_foreign_key "blueprints", "users"
  add_foreign_key "chat_messages", "chat_rooms"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "chat_rooms", "locations"
  add_foreign_key "corp_applications", "corporations"
  add_foreign_key "corp_applications", "users"
  add_foreign_key "corporations", "chat_rooms"
  add_foreign_key "craft_jobs", "locations"
  add_foreign_key "craft_jobs", "users"
  add_foreign_key "factions", "locations"
  add_foreign_key "finance_histories", "corporations"
  add_foreign_key "finance_histories", "users"
  add_foreign_key "fleets", "chat_rooms"
  add_foreign_key "fleets", "users"
  add_foreign_key "items", "locations"
  add_foreign_key "items", "missions"
  add_foreign_key "items", "spaceships"
  add_foreign_key "items", "users"
  add_foreign_key "locations", "factions"
  add_foreign_key "locations", "missions"
  add_foreign_key "locations", "systems"
  add_foreign_key "market_listings", "locations"
  add_foreign_key "missions", "factions"
  add_foreign_key "missions", "locations"
  add_foreign_key "missions", "users"
  add_foreign_key "npcs", "locations"
  add_foreign_key "spaceships", "locations"
  add_foreign_key "spaceships", "users"
  add_foreign_key "structures", "locations"
  add_foreign_key "structures", "users"
  add_foreign_key "thredded_messageboard_users", "thredded_messageboards", on_delete: :cascade
  add_foreign_key "thredded_messageboard_users", "thredded_user_details", on_delete: :cascade
  add_foreign_key "thredded_user_post_notifications", "thredded_posts", column: "post_id", on_delete: :cascade
  add_foreign_key "thredded_user_post_notifications", "users", on_delete: :cascade
  add_foreign_key "users", "corporations"
  add_foreign_key "users", "factions"
  add_foreign_key "users", "fleets"
  add_foreign_key "users", "locations"
  add_foreign_key "users", "systems"
end
