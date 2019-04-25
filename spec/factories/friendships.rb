# == Schema Information
#
# Table name: friendships
#
#  id         :bigint(8)        not null, primary key
#  accepted   :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  friend_id  :integer
#  user_id    :integer
#
# Indexes
#
#  index_friendships_on_friend_id  (friend_id)
#  index_friendships_on_user_id    (user_id)
#

FactoryBot.define do
  factory :friendship do
    user_id { 1 }
    friend_id { 1 }
    accepted { false }
  end
end
