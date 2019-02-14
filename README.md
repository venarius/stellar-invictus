# Stellar Invictus

## Roadmap

- ~~Asteroids - Rename Ore~~
- ~~Enhance map~~
- ~~Fleets~~
- ~~Crafting~~
- ~~Corporations~~
- ~~Bio for Users~~
- ~~Friends~~
- ~~Drop Items -> Container~~
- ~~Loot on destroyed enemies / players~~
- ~~Animated Spaceships~~
- ~~Time to get into warp~~
- ~~Equipment System~~
- ~~Warp Scramble, Warp Stabilizer~~
- ~~Repair Equipment -> Repair Bots~~
- ~~New Fight System -> Button for each Weapon, Septarium Usage~~
- ~~Custom Chatchannels~~
- ~~Time to target~~
- ~~Panelty for Combatlogging -> Drop random loot as container~~
- ~~Asset Overview -> Show where you have what ships / items~~
- ~~Bounty System~~
- ~~Missions~~
- Planetary Interaction -> Rebid every month to maintain
- ~~Expeditions -> Quiz for loot -> Worker to randomly place hidden Locations in Systems~~
- ~~Small Description for each item type~~
- ~~Trading System~~
- ~~More Ships~~
- ~~Faction Bonuses~~
- ~~Faction Reputation - Unlocks on different levels -> Faction Ships~~
- ~~About -> Currently empty site~~
- ~~Warp to Fleet Members~~
- ~~More different Stations with their own traits -> https://forums.frontier.co.uk/showthread.php/462896-new-station-ideas~~
- ~~Main equipment to buff other pilots~~
- ~~Ship Descriptions, Classes, Bonuses~~
- ~~Player Reporting -> Support Tickets~~
- Player-Owned Stations -> 1 per System
- Killboard
- ~~Admin Backend -> Scheduled Server Downtime~~
- ~~Invite Players to join ChatRoom~~
- ~~Vote for Changes~~
- Help Site
- ~~Enemy Bounty random~~
- ~~Remove Sleep from Workers !Important~~
- ~~Fast movement of many items -> Store / Load~~
- ~~Bug Reporting~~
- ~~Forum / Subreddit~~
- ~~Newbie Channel with ID "ROOKIES"~~
- ~~Stations Overview empty~~
- ~~Factory -> Buy Blueprint -> Can now build next ship~~
- ~~Better Map -> visjs.org~~
- ~~Routing System -> See what jumpgates to take to get from A to B~~
- ~~Bounty Hunting for NPCs hiding in their hidden homes -> need scanner -> lots of bounty~~
- ~~Rework Material Requirements and Prices on Items / Ships (Titanium Ore) -> Defense can't be more than 90~~
- ~~Improve Code with Rubycritic~~
- ~~Add Info about Pilots Ship in User Modal~~
- ~~Cargo Jettison -> Be able to submit how much~~
- ~~Store / Load -> "All" Button~~
- ~~Should not reload ship info after npc died (performance)~~
- ~~Notify for successfully accepted mission / finished mission~~
- ~~Missions / Market more specific to Station~~
- ~~Modal on Faction Choose with Intro and how to find Help~~
- ~~More Stations that belong to the main factions -> sell faction ships, missions where to kill another npc who has information in other faction space~~
- ~~Registration Mail Flash not showing~~
- ~~If standing is bad, stations of this faction will refuse your dockrequest~~
- ~~Better Errors for ChatRooms join / create -> notfiy?~~
- ~~Overhaul Root Page~~
- ~~Redesign Devise Mails -> Change E-Mail to no-reply@stellar-invictus.com and find smtp service~~
- ~~Mobile Tables (overflow: ellipsis) -> corporation (like players table)~~
- ~~Rules from Faction to TOS (Copy from EVE Online TOS)~~
- ~~Forum from Thredded to Discourse -> forums.stellar-invictus.com~~
 
## Installation

Run the following commands on the app machine:
```
adduser deploy
sudo visudo -> deploy ALL=(ALL) NOPASSWD: ALL
$switch to user deploy

sudo add-apt-repository ppa:chris-lea/redis-server
sudo apt update
sudo apt install redis-server
systemctl enable redis-server

$rvm.io install
source /home/deploy/.rvm/scripts/rvm
rvm install ruby-2.5.3
sudo apt install nodejs
sudo apt install libpq-dev

$yarn install

sudo apt install nginx ufw
sudo ufw allow 'Nginx Full'

ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -> GitHub

vi /etc/apt/apt.conf.d/10periodic -> APT::Periodic::Update-Package-Lists "0";
```

Run the following commands on the db machine:
```
adduser deploy
sudo visudo -> deploy ALL=(ALL) NOPASSWD: ALL
$switch to user deploy
sudo apt install postgresql postgresql-contrib

$rvm.io install
source /home/deploy/.rvm/scripts/rvm
rvm install ruby-2.5.3
sudo apt install nodejs
sudo apt install libpq-dev

sudo su
vi /etc/postgresql/10/main/pg_hba.conf -> host all $app-ip/32 md5, host all $db-ip/32 md5
vi /etc/postgresql/10/main/postgresql.conf -> listen_addresses = '*'
service postgresql restart
systemctl enable postgresql

ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -> GitHub

vi /etc/apt/apt.conf.d/10periodic -> APT::Periodic::Update-Package-Lists "0";
```


After that:
1. Copy master.key from rails project to deployment_machine:/home/deploy/app/stellar/shared/config/master.key
2. Copy .env.sample in project root to .env in /app/stellar/shared and fill out informations
2. Change IP of Server in Deploy Config to deployment_machine
3. Run cap production setup
5. Run cap production deploy

## After every new thing
```
rake economy:redo
rake pathfinder:generate_paths
rake pathfinder:generate_mapdata
```

## Help

How to start puma on server if crashed:
```
bundle exec pumactl -S /home/deploy/app/stellar/shared/tmp/pids/puma.state -F /home/deploy/app/stellar/shared/puma.rb restart

OR

~/.rvm/bin/rvm default do bundle exec puma -C /home/deploy/app/stellar/shared/puma.rb --daemon

OR

cap production deploy:restart
```

How to start sidekiq on server if crashed:
```
export RAILS_ENV="production" ; ~/.rvm/bin/rvm default do bundle exec sidekiqctl stop /home/deploy/app/stellar/shared/tmp/pids/sidekiq-0.pid 10

OR

~/.rvm/bin/rvm default do bundle exec sidekiq --index 0 --pidfile /home/deploy/app/stellar/shared/tmp/pids/sidekiq-0.pid --environment production --logfile /home/deploy/app/stellar/shared/log/sidekiq.log --daemon
```


# Nginx Config
```
server { 
  listen 443;
  ssl on;
  ssl_certificate /home/deploy/app/stellar/shared/certificates/stellar-invictus_com.crt;
  ssl_certificate_key /home/deploy/app/stellar/shared/certificates/stellar-invictus_com.key;
  server_name localhost www.stellar-invictus.com stellar-invictus.com;
  
  root /home/deploy/app/stellar/current/public;

  # Turn on Passenger
  passenger_enabled on;
  passenger_ruby /path-to-ruby;
}
```