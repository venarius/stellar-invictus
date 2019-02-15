web: bundle exec rake clean:restart & bundle exec rake pathfinder:generate_paths & bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -t 25