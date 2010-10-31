desc "Expire challenges"
task :cron => :environment do
  DataMapper::Logger.new($stdout, :debug)
  puts "Executing challenge expiration cron at #{DateTime.now}"
  to_expire = Challenge.to_expire
  to_expire.each do |c|
    c.expire!
    puts "Challenge #{c.id} expired"
  end
  puts "TOTAL: #{to_expire.count} challenge(s) expired at #{DateTime.now}"
end