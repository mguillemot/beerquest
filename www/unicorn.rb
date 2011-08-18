APP_PATH = "/home/ruby/www.bq-4.com/www"
LOG_PATH = "/var/log/unicorn"
SYS_PATH = "/var/run/unicorn"

worker_processes  1 # Because there isn't much power on this box...
working_directory APP_PATH
listen            "#{SYS_PATH}/beerquest.socket", :backlog => 64
timeout           30
user              "www-data"
pid               "#{SYS_PATH}/beerquest.pid"
stderr_path       "#{LOG_PATH}/beerquest.stderr.log"
stdout_path       "#{LOG_PATH}/beerquest.stdout.log"