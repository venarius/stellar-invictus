# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# CraftingJobs
every 1.minutes, roles: [:db] do
  runner "runner/crafting_job.rb"
end

# Economy Redo
every 10.minutes, roles: [:db] do
  runner "runner/economy_redo.rb"
end

# Hidden Locations
every 15.minutes, roles: [:db] do
  runner "runner/hidden_locations.rb"
end

# Mission Cleaner
every 30.minutes, roles: [:db] do
  runner "runner/mission_cleaner.rb"
end

# Hidden Enemies
every 1.minutes, roles: [:db] do
  runner "runner/hidden_enemies.rb"
end

# Asteroids Redo
every 2.hours, roles: [:db] do
  runner "runner/asteroids_redo.rb"
end

# Wormholes
every 10.minutes, roles: [:app] do
  runner "runner/wormholes.rb"
end
