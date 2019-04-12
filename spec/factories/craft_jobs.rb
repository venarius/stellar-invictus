# == Schema Information
#
# Table name: craft_jobs
#
#  id           :bigint(8)        not null, primary key
#  completed_at :datetime
#  loader       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  location_id  :bigint(8)
#  user_id      :bigint(8)
#
# Indexes
#
#  index_craft_jobs_on_completed_at  (completed_at)
#  index_craft_jobs_on_location_id   (location_id)
#  index_craft_jobs_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :craft_job do
    completed_at { Time.now.utc + 1.hour }
    loader { 'MyString' }
    user { nil }
  end
end
