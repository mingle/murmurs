Gem::Specification.new do |s|
  s.name = 'murmurs'
  s.version = '0.1.0'
  s.summary = 'Post murmur to Mingle project murmurs'
  s.description = <<-EOF
Post murmur to your Mingle project from command line.
Git post-receive hook to post murmurs when new commits pushed to Git server.
EOF
  s.license = 'MIT'
  s.authors = ["ThoughtWorks Mingle Team"]
  s.email = ['mingle-dev@thoughtworks.com']
  s.homepage = 'https://github.com/ThoughtWorksStudios/murmurs'

  s.add_dependency "api-auth", ">= 1.0.3"

  s.bindir = "bin"
  s.executables = ["murmurs"]

  s.files = ['README.md']
  s.files += Dir['bin/**/*']
  s.files += Dir['lib/**/*.rb']
end
