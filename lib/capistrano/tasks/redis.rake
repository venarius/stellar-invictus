set_default(:redis_pid, "/var/run/redis/redis-server.pid")
set_default(:redis_port, 6379)


namespace :redis do
  desc "Install the latest release of Redis"
  task :install, roles: :app do
    run "#{sudo} yum install -y redis"
  end
  after "deploy:install", "redis:install"

  # Just to use if you need to do more than the default configuration, mind to change the monit script details as well
  # desc "Setup Redis"
  # task :setup do
  #   run "#{sudo} cp /etc/redis/redis.conf /etc/redis/redis.conf.default"
  #   template "redis.conf.erb", "/tmp/redis.conf"
  #   run "#{sudo} mv /tmp/redis.conf /etc/redis/redis.conf"
  #   restart
  # end
  # after "deploy:setup", "redis:setup"

  %w[start stop restart].each do |command|
    desc "#{command} redis"
    task command, roles: :web do
      run "#{sudo} service redis #{command}"
    end
  end
end