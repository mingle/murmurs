
task :default => [:test, :install]

task :install do
  puts `rm -rf murmurs-*`
  puts `gem build murmurs.gemspec`
  puts `gem install murmurs-*`
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*test.rb']
  t.verbose = true
end
