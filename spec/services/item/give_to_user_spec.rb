# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item::GiveToUser, type: :service do

  let(:user) { create :user_with_location }

  it 'should give item to user' do
    Item::GiveToUser.(
      amount: 10,
      loader: Item::ITEMS.sample,
      user: user,
      location: user.location)

    expect(user.items.count).to eq(1)
    expect(user.items.first.count).to eq(10)
  end
end
