FactoryBot.define do
  factory :mission do
    mission_type { 1 }
    mission_status { 1 }
    agent_name { "MyString" }
    agent_avatar { "MyString" }
    text { 1 }
    reward { 1 }
    faction { nil }
    user { nil }
    difficulty { 1 }
    enemy_amount { 1 }
    mission_loader { "MyString" }
    mission_amount { 1 }
    faction_bonus { 1.5 }
    faction_malus { 1.5 }

    factory :combat_mission do
      mission_type { 2 }
      mission_location { Location.first }
      faction { Faction.first }
      location { Location.first }
    end

  end
end
