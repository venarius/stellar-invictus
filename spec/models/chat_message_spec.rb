# == Schema Information
#
# Table name: chat_messages
#
#  id           :bigint(8)        not null, primary key
#  body         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chat_room_id :bigint(8)
#  user_id      :bigint(8)
#
# Indexes
#
#  index_chat_messages_on_chat_room_id  (chat_room_id)
#  index_chat_messages_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (chat_room_id => chat_rooms.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

describe ChatMessage do
  context 'new chat message' do
    describe 'attributes' do
      it { should respond_to :user }
      it { should respond_to :body }
    end

    describe 'Relations' do
      it { should belong_to :user }
    end

    describe 'Validations' do
      describe 'body' do
        it { should validate_presence_of :body }
        it { should validate_length_of :body }
        it { should allow_values('Hello there').for :body }
        it { should_not allow_values('', nil).for :body }
      end
    end
  end
end
