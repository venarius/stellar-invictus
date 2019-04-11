Sidekiq.configure_server do |config|
  # NOTE: While this may be necessary, this will cause Sidekiq to pound your Redis server
  # polling for jobs - which is why Mike Perham says that Sidekiq isn't suited for precision timing
  config.average_scheduled_poll_interval = 0.05
end
