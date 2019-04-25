# == Schema Information
#
# Table name: chat_rooms
#
#  id            :bigint(8)        not null, primary key
#  chatroom_type :integer
#  identifier    :string
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  location_id   :bigint(8)
#  system_id     :bigint(8)
#
# Indexes
#
#  index_chat_rooms_on_chatroom_type  (chatroom_type)
#  index_chat_rooms_on_identifier     (identifier) UNIQUE
#  index_chat_rooms_on_location_id    (location_id)
#  index_chat_rooms_on_system_id      (system_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (system_id => systems.id)
#

require 'rails_helper'

describe ChatRoom do
  context 'new chat room' do
    describe 'attributes' do
      it { should respond_to :users }
      it { should respond_to :title }
      it { should respond_to :chat_messages }
      it { should respond_to :location }
      it { should respond_to :system }
    end

    describe 'Relations' do
      it { should have_and_belong_to_many :users }
      it { should have_many :chat_messages }
    end

    describe 'Validations' do
      describe 'title' do
        it { should validate_presence_of :title }
        it { should validate_length_of :title }
        it { should allow_values('Hello there').for :title }
        it { should_not allow_values('', nil, 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA').for :title }
      end
    end

    describe 'Enums' do
      it { should define_enum_for(:chatroom_type).with_values([:global, :local, :custom, :corporation]) }
    end

    describe 'Functions' do
      describe 'update_local_players' do
        it 'should send actioncable' do
          room = create(:chat_room)
          room.update_local_players
        end
      end
    end
  end
end
