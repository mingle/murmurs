Gem::Specification.new do |s|
  s.name = 'murmurs'
  s.version = '0.1.2'
  s.summary = 'Integrate Git with your Mingle project'
  s.description = <<-EOF
Itegrate Git with your Mingle project by posting murmurs to your Mingle project when new commits got pushed to Git server.
This gem provides command to generate Git post-receive hook and post murmurs to your Mingle project.
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
