require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Stellar
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    
    # Sidekiq
    config.active_job.queue_adapter = :sidekiq
    
    # Custom
    if defined?(Rails::Server)
      config.after_initialize do
        begin
          # User
          User.all.each do |user|
             user.update_columns(online: 0, in_warp: false, target_id: nil, mining_target_id: nil, npc_target_id: nil, is_attacking: false)
             user.update_columns(docked: false) if user.docked.nil?
          end
          
          # Asteroids
          Asteroid.destroy_all
          Location.where(location_type: 'asteroid_field').each do |loc|
            rand(5..10).times do 
              Asteroid.create(location: loc, asteroid_type: rand(3), resources: 35000)
            end
            rand(3..5).times do 
              Asteroid.create(location: loc, asteroid_type: 3, resources: 35000)
            end
          end
          
          # NPC
          Npc.destroy_all
          
          # Cargocontainer
          Structure.where(structure_type: 'container').destroy_all
          # Wrecks
          Structure.where(structure_type: 'wreck').destroy_all
          
          # Ships
          Spaceship.all.each do |ship|
            ship.update_columns(warp_scrambled: false, warp_target_id: nil)
          end
          
          # Items
          Item.all.each do |item|
            item.update_columns(active: false)
          end
        rescue StandardError
          true
        end
      end
    end
  end
end