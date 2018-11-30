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