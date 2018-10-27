# Stellar Invictus

## Installation

Run the following commands on the deployment machine:
```
adduser tla
sudo visudo -> tla ALL=(ALL) NOPASSWD: ALL
sudo apt install postgresql postgresql-contrib

sudo su
vi /etc/postgresql/10/main/pg_hba.conf -> local all all trust
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
```

After that:
1. Copy master.key from rails project to deployment_machine:/home/app/stellar/shared/config/master.key
2. Run cap production setup
3. Run cap production deploy
