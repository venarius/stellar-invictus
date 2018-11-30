# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"
require 'capistrano/rails'

# SCM GIT
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
require "capistrano/rvm"
require "capistrano/bundler"
require 'capistrano/sidekiq'
require 'capistrano/postgresql'

# Whenever
require "whenever/capistrano"

# Puma
require 'capistrano/puma'
install_plugin Capistrano::Puma  # Default puma tasks
install_plugin Capistrano::Puma::Nginx

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
