# == Schema Information
#
# Table name: systems
#
#  id              :bigint(8)        not null, primary key
#  name            :string
#  security_status :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_systems_on_name  (name) UNIQUE
#

FactoryBot.define do
  factory :system do
    name { Faker::Space.galaxy }

    factory :high_sec_system do
      security_status { 0 }
    end

    factory :mid_sec_system do
      security_status { 1 }
    end

    factory :low_sec_system do
      security_status { 2 }
    end
  end
end
