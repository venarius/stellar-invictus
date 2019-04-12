# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Disappear, type: :service do
  include ActiveJob::TestHelper

  let(:user) { create :user_with_faction }

  it 'should decrement online counter and send "player_warp_out"' do
    expect {
      User::Disappear.(user: user)
    }.to change { user.online }.by(-1)
    assert_broadcast_method(user.location.channel_id, 'player_warp_out')
  end

  it 'should send message to custom chat_room' do
    expect_any_instance_of(System).to receive(:update_local_players).and_return(true)
    expect_any_instance_of(ChatRoom).to receive(:update_local_players).and_return(true)

    user.update(docked: false)
    room = create :chat_room, chatroom_type: :custom
    room.users << user
    user.reload

    User::Disappear.(user: user)

    assert_broadcast_method(user.location.channel_id, 'player_warp_out')
  end

end
