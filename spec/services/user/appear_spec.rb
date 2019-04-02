# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Appear, type: :service do
  include ActionCable::TestHelper

  let(:user) { create :user_with_location }

  it 'should increment online' do
    User::Appear.(user: user)
    assert_broadcasts user.location.channel_id, 1
    expect(user.reload.online).to eq(1)
  end
end
