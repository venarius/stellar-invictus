FactoryBot.define do
  factory :npc do
    npc_type { 0 }
    location { nil }

    factory :npc_police do
      npc_type { 1 }
    end
  end
end
