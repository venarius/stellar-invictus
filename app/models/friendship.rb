class Friendship < ApplicationRecord
  after_create :create_inverse_relationship
  after_destroy :destroy_inverse_relationship

  belongs_to :user
  belongs_to :friend, class_name: 'User'

  delegate :avatar, :full_name, to: :user, prefix: true
  delegate :avatar, :full_name, to: :friend, prefix: true

  private

  def create_inverse_relationship
    if self.accepted && friend.friendships.where(friend: user).empty?
      friend.friendships.create(friend: user, accepted: false)
    end
  end

  def destroy_inverse_relationship
    friendship = friend.friendships.find_by(friend: user)
    friendship.destroy if friendship
  end
end
