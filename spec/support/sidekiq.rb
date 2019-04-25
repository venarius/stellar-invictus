# frozen_string_literal: true

require 'sidekiq/testing'
Sidekiq::Testing.fake!

# Sidekiq
RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end
