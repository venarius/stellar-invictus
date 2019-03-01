#!/bin/bash
set -e

cd /home/app/webapp

# Basic Rake Tasks
rvm-exec 2.5.3 bundle exec rake pathfinder:generate_mapdata RAILS_ENV=production
rvm-exec 2.5.3 bundle exec rake pathfinder:generate_paths RAILS_ENV=production

exec "$@"