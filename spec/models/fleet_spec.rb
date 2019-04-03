# == Schema Information
#
# Table name: fleets
#
#  id           :bigint(8)        not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chat_room_id :bigint(8)
#  user_id      :bigint(8)
#
# Indexes
#
#  index_fleets_on_chat_room_id  (chat_room_id)
#  index_fleets_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (chat_room_id => chat_rooms.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

describe Fleet do
  context 'new fleet' do
    describe 'attributes' do
      it { should respond_to :creator }
      it { should respond_to :users }
      it { should respond_to :chat_room }
    end

    describe 'Relations' do
      it { should belong_to :chat_room }
      it { should belong_to :creator }
      it { should have_many :users }
    end

    describe 'Functions' do
      describe 'before_destroy' do
        it 'should remove all active users from fleet' do
          user = create(:user_with_faction)
          fleet = create(:fleet, creator: user)
          fleet.users << user
          fleet.destroy
          expect(user.reload.fleet).to eq(nil)
        end
      end
    end
  end
end
