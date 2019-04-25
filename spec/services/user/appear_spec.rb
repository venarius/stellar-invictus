# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Appear, type: :service do

  let(:user) { create :user_with_location }

  it 'should increment online counter and send "player_appeared"' do
    user.update(online: 0)
    expect {
      User::Appear.(user: user)
    }.to change { user.online }.by(1)
    assert_broadcast_method(user.location.channel_id, 'player_appeared')
    assert_broadcast_method(user.location.channel_id, 'update_players_in_system')
  end

  it 'should increment online counter' do
    user.increment!(:online)
    expect {
      User::Appear.(user: user)
    }.to change { user.online }.by(1)
    assert_broadcast_method(user.location.channel_id, 'update_players_in_system')
  end

  it 'should send message to custom chat_room' do
    room = create :chat_room, chatroom_type: :custom
    room.users << user
    User::Appear.(user: user)
    assert_broadcast_method(user.location.channel_id, 'update_players_in_system')
  end

end
