Gem::Specification.new do |s|
  s.name = 'murmurs'
  s.version = '0.0.2'
  s.summary = 'Post murmur to Mingle project murmurs'
  s.description = <<-EOF
Use HMAC to create murmur in Mingle project.
Git post-receive hook to post murmurs when new commits pushed to Git server.
EOF
  s.license = 'MIT'
  s.authors = ["ThoughtWorks Mingle Team"]
  s.email = ['mingle-dev@thoughtworks.com']
  s.homepage = 'https://github.com/ThoughtWorksStudios/murmurs'

  s.add_dependency "api-auth", ">= 1.1.0"
  s.add_dependency "json", ">= 1.8.1"

  s.bindir = "bin"
  s.executables = ["murmurs", "murmurs-git"]

  s.files = ['README.md']
  s.files += Dir['bin/**/*']
  s.files += Dir['lib/**/*.rb']
end
