source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'rails', '~> 5.2.1'
gem 'sqlite3'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jquery-rails'
# Use Redis adapter to run Action Cable in production
gem 'redis'

gem 'bootsnap', '>= 1.1.0', require: false

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'bullet'
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-postgresql'
  gem 'capistrano-rvm'
  gem 'capistrano-sidekiq'
  gem 'capistrano3-puma'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'simplecov'
end

group :production, :development do
  gem 'pg'
end


# Authentication through devise
gem 'devise'
# Client-Side Validations
gem 'client_side_validations'
# Sidekiq for Jobs
gem 'sidekiq'
# Pagination
gem 'kaminari'
gem 'bootstrap4-kaminari-views'
# Faker for Names
gem 'faker'
# Redcarpet for Markdown Player Bios
gem 'redcarpet'
# Jquery-UI for drag and drop
gem 'jquery-ui-rails'
# Whenever for CronJobs
gem 'whenever', require: false
# Perlin Noise for Market
gem 'perlin_noise'
# Dotenv for ENV Variables
gem 'dotenv-rails'