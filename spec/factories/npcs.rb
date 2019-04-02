FactoryBot.define do
  factory :npc do
    npc_type { :enemy }

    factory :npc_police do
      npc_type { :police }
    end
  end
end
