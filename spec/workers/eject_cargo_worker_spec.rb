# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EjectCargoWorker, type: :worker do
  #  def perform(user_id, loader, amount)
  let(:user) { create :user_with_faction }
  let(:loader) { 'asteroid.nickel_ore' }
  before(:each) do
    create :item, spaceship: user.ship, loader: loader, count: 10
  end

  it 'should do nothing unless user' do
    expect {
      subject.perform(-1, loader, 10)
    }.not_to change(Item, :count)
  end

  it 'should do nothing unless user has loader' do
    expect {
      subject.perform(user, 'something.else', 10)
    }.not_to change(Item, :count)
  end

  it 'should create structure with removed items' do
    expect {
      subject.perform(user, loader, 10)
    }.to change(Structure, :count).by(1)
    user.reload
    expect(user.ship.items.count).to eq(0)
  end

end
