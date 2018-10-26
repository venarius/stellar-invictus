# Stellar Invictus

## Installation

Run the following commands on the deployment machine:
```
sudo yum install postgresql-server postgresql-contrib
sudo postgresql-setup initdb
sudo systemctl enable postgresql

sudo bash
vi /var/lib/pgsql/data/pg_hba.conf -> local all all trust
service postgresql restart
exit

sudo yum install epel-release
sudo yum update
sudo yum install -y redis
sudo systemctl enable redis

$rvm.io install
source /home/tla/.rvm/scripts/rvm
rvm install ruby
sudo yum install -y git
sudo yum -y install nodejs
sudo visudo -> $user ALL=(ALL) NOPASSWD: ALL
sudo yum install -y postgresql-devel

$yarn install
```

After that:
1. Copy master.key from rails project to deployment_machine:/home/app/stellar/shared/config/master.key
2. Run cap production setup
3. Run cap production deploy