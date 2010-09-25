worker_processes 4
working_directory "/var/www/beerquest/www"
listen "/tmp/beerquest.socket", :backlog => 64
timeout 30
user "www-data"
shared_path = "/var/www/beerquest/shared"
pid "#{shared_path}/pids/unicorn.pid"
stderr_path "#{shared_path}/log/unicorn.stderr.log"
stdout_path "#{shared_path}/log/unicorn.stdout.log"