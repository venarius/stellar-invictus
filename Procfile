web: ./passenger-status-service-agent & bundle exec passenger start -p $PORT
web: bundle exec sidekiq -c 2
web: bundle exec rake clean:restart