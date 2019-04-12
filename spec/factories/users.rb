# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  admin                  :boolean
#  avatar                 :string
#  banned                 :boolean
#  banned_until           :datetime
#  banreason              :string
#  bio                    :text
#  bounty                 :integer          default(0)
#  bounty_claimed         :integer          default(0)
#  chat_mod               :boolean          default(FALSE)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  corporation_role       :integer          default("recruit")
#  docked                 :boolean          default(FALSE)
#  donator                :boolean          default(FALSE)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  equipment_worker       :boolean          default(FALSE)
#  family_name            :string
#  full_name              :string
#  in_warp                :boolean          default(FALSE)
#  is_attacking           :boolean
#  last_action            :datetime
#  logout_timer           :boolean          default(FALSE)
#  muted                  :boolean          default(FALSE)
#  name                   :string
#  online                 :integer          default(0)
#  provider               :string
#  remember_created_at    :datetime
#  reputation_1           :float            default(0.0)
#  reputation_2           :float            default(0.0)
#  reputation_3           :float            default(0.0)
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  route                  :string           default([]), is an Array
#  uid                    :string
#  units                  :integer          default(10)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  active_spaceship_id    :integer
#  corporation_id         :bigint(8)
#  faction_id             :bigint(8)
#  fleet_id               :bigint(8)
#  location_id            :bigint(8)
#  mining_target_id       :integer
#  npc_target_id          :integer
#  system_id              :bigint(8)
#  target_id              :integer
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_corporation_id        (corporation_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_faction_id            (faction_id)
#  index_users_on_family_name_and_name  (family_name,name) UNIQUE
#  index_users_on_fleet_id              (fleet_id)
#  index_users_on_location_id           (location_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_system_id             (system_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#  fk_rails_...  (faction_id => factions.id)
#  fk_rails_...  (fleet_id => fleets.id)
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (system_id => systems.id)
#

FactoryBot.define do

  factory :user do
    pass = Faker::Internet.password(6)

    email { Faker::Internet.email }
    password { pass }
    password_confirmation { pass }
    name { "#{Faker::Name.first_name}AA" }
    family_name { "#{Faker::Name.first_name}AA" }
    avatar { 'M_1' }
    confirmed_at { Date.today }
    docked { false }
    online { 1 }

    factory :user_with_location do
      system { System.all.sample   }
      location { system.locations.sample }
      active_spaceship { create(:spaceship) }

      factory :user_with_faction do
        faction { Faction.first }
      end
    end

    factory :user_without_spaceship do
      faction { Faction.first }
      system { System.first }
      location { system.locations.first }
    end
  end

  factory :faction do
    name { Faker::Fallout.faction }
    description { Faker::Lorem.sentences }
  end

end
