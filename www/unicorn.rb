APP_PATH = "/home/www/www.bq-4.com/www"
LOG_PATH = "/home/www/www.bq-4.com/www/log"
SYS_PATH = "/var/run/unicorn"


worker_processes 4
working_directory APP_PATH
listen "#{SYS_PATH}/beerquest.socket", :backlog => 64
timeout 30
user "www-data"
pid "#{SYS_PATH}/beerquest.pid"
stderr_path "#{LOG_PATH}/unicorn.stderr.log"
stdout_path "#{LOG_PATH}/unicorn.stdout.log"