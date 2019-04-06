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

class Friendship < ApplicationRecord
  ## -- RELATIONSHIPS
  belongs_to :user
  belongs_to :friend, class_name: User.name

  ## -- CALLBACKS
  after_create :create_inverse_relationship
  after_destroy :destroy_inverse_relationship

  ## -- SCOPES
  scope :is_request, -> { where(accepted: [false, nil]) }

  ## — INSTANCE METHODS
  def friend_avatar_url
    "avatars/#{self.friend.avatar}.jpg"
  end

  def user_avatar_url
    "avatars/#{self.user.avatar}.jpg"
  end

  private

  def create_inverse_relationship
    if self.accepted && friend.friendships.where(friend: user).empty?
      friend.friendships.create(friend: user, accepted: false)
    end
  end

  def destroy_inverse_relationship
    friendship = friend.friendships.where(friend: user).first
    friendship.destroy if friendship
  end
end
