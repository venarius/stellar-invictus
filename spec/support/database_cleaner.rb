# frozen_string_literal: true

require 'database_cleaner'

# Database Cleaner
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)

    # Seed Database
    Rails.application.load_seed

    Asteroid.destroy_all
    Location.asteroid_field.each do |loc|
      rand(5..10).times do
        Asteroid.create(location: loc, asteroid_type: rand(3), resources: 35000)
      end
    end
  end

  config.before(:all) do
    DatabaseCleaner.start
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.after(:all) do
    DatabaseCleaner.clean
  end

end
