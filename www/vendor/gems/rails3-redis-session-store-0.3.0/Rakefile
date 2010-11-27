require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rails3-redis-session-store"
    gem.summary = %Q{Rails 3 Redis session store }
    gem.description = %Q{A drop-in replacement for e.g. MemCacheStore to store Rails sessions (and Rails sessions only) in Redis.}
    gem.email = "ivan@flanders.co.nz"
    gem.homepage = "http://github.com/casualjim/redis-session-store"
    gem.authors = ["Mathias Meyer", "Ivan Porto Carrero"]
    gem.add_runtime_dependency  "redis"
    gem.require_path = "lib"
    gem.files = FileList['[A-Z]*', "{lib/**/*}"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
