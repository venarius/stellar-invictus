# Stellar Invictus

## Roadmap

- ~~Asteroids - Rename Ore~~
- Enhance map
- ~~Fleets~~
- ~~Crafting~~
- Alliances
- Skills -> Kills with specific ship -> Bonuses
- ~~Bio for Users~~
- ~~Friends~~
- ~~Drop Items -> Container~~
- ~~Loot on destroyed enemies / players~~
- ~~Animated Spaceships~~
- Trading between Players
- ~~Time to get into warp~~
- ~~Equipment System~~
- ~~Warp Scramble, Warp Stabilizer~~
- ~~Repair Equipment -> Repair Bots~~
- ~~New Fight System -> Button for each Weapon, Septarium Usage~~
- ~~Custom Chatchannels~~
- ~~Time to target~~
- ~~Panelty for Combatlogging -> Drop random loot as container~~
- ~~Asset Overview -> Show where you have what ships / items~~
- Missions
- Planetary Interaction
- Expeditions -> Quiz for loot -> Worker to randomly place hidden Locations in Systems
- Trading System
- More Ships
- ~~Faction Bonuses~~
- Faction Reputation - Unlocks on different levels
- Home, About -> Currently empty sites
- Player Reporting
- Achievements
- Killboard
- Statistics
- Admin Backend
- Vote for Changes

## Installation

Run the following commands on the deployment machine:
```
adduser tla
sudo visudo -> tla ALL=(ALL) NOPASSWD: ALL
$switch to user tla
sudo apt install postgresql postgresql-contrib

sudo su
vi /etc/postgresql/10/main/pg_hba.conf -> local all all trust
vi /etc/postgresql/10/main/postgresql.conf -> max_connection = 1000, shared_buffers = 400mb
service postgresql restart
systemctl enable postgresql
exit

sudo apt install redis
systemctl enable redis-server

$rvm.io install
source /home/tla/.rvm/scripts/rvm
rvm install ruby
sudo apt install nodejs
sudo apt install libpq-dev

$yarn install

sudo apt install nginx
sudo ufw allow 'Nginx Full'

ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -> GitHub
```

After that:
1. Copy master.key from rails project to deployment_machine:/home/app/stellar/shared/config/master.key
2. Change IP of Server in Deploy Config to deployment_machine
3. Copy certificates to /home/app/stellar/shared/certificates
4. Run cap production setup
5. Run cap production puma:nginx_config
6. Run cap production deploy

## Daily Maintenance / On Crash

Run the following command in rails console on deployment machine:
```
# User
User.all.each do |user|
   user.update_columns(online: 0, in_warp: false, target_id: nil, mining_target_id: nil, npc_target_id: nil, is_attacking: false)
   user.update_columns(docked: false) if user.docked.nil?
end

# Asteroids
Asteroid.destroy_all
Location.where(location_type: 'asteroid_field').each do |loc|
  rand(5..10).times do 
    Asteroid.create(location: loc, asteroid_type: rand(3), resources: 35000)
  end
  rand(3..5).times do 
    Asteroid.create(location: loc, asteroid_type: 3, resources: 35000)
  end
end

# NPC
Npc.destroy_all

# Cargocontainer
Structure.where(structure_type: 'container').destroy_all
# Wrecks
Structure.where(structure_type: 'wreck').destroy_all

# Ships
Spaceship.all.each do |ship|
  ship.update_columns(warp_scrambled: false, warp_target_id: nil)
end

# Items
Item.all.each do |item|
  item.update_columns(active: false)
end
```

Then run the following on develop environment:
```
cap production puma:restart
```