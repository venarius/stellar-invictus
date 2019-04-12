# frozen_string_literal: true

require 'action_cable/testing/rspec'

module ActionCable::TestHelper

  def assert_broadcast_method(stream, value)
    new_messages = broadcasts(stream)
    if block_given?
      old_messages = new_messages
      clear_messages(stream)

      yield
      new_messages = broadcasts(stream)
      clear_messages(stream)

      # Restore all sent messages
      (old_messages + new_messages).each { |m| pubsub_adapter.broadcast(stream, m) }
    end

    message = new_messages.find do |msg|
      ActiveSupport::JSON.decode(msg)['method'] == value
    end

    assert message, "No messages sent with method(\"#{value})\") to #{stream}"
  end

end

RSpec.configure do |config|
  config.include ActionCable::TestHelper, type: :service
  config.include ActionCable::TestHelper, type: :worker
end
