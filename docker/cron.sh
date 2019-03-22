#!/bin/bash
set -e

cd /home/app/webapp

rvm-exec 2.5.3 bundle exec whenever --update-crontab
mkdir ./log
touch ./log/cron.log
cron
tail -f ./log/cron.log