web: bundle exec rake clean:restart &  bundle exec rake pathfinder:generate_paths &  bundle exec rake pathfinder:generate_mapdata & bundle exec sidekiq -c 2 & bundle exec passenger start -p $PORT --max-pool-size 3