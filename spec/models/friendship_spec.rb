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

require 'rails_helper'

describe Friendship do
  context 'new friendship' do
    describe 'attributes' do
      it { should respond_to :user }
      it { should respond_to :friend }
    end

    describe 'Relations' do
      it { should belong_to :user }
      it { should belong_to :friend }
    end
  end
end
