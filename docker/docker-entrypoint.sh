#!/bin/bash
set -e

cd /myapp

# Basic Rake Tasks
rake pathfinder:generate_mapdata
rake pathfinder:generate_paths

exec "$@"