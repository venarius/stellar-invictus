#!/bin/bash
set -e

cd /usr/src/app

# Basic Rake Tasks
rake pathfinder:generate_mapdata
rake pathfinder:generate_paths
rake clean:restart

# Set Whenever
whenever --update-crontab

exec "$@"