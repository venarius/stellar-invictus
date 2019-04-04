# frozen_string_literal: true

require 'devise'

# Devise
RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
end
