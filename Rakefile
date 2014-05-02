
task :default => :install

task :install do
  puts `rm -rf murmurs-*`
  puts `gem build murmurs.gemspec`
  puts `gem install murmurs-*`
end
