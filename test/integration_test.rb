require 'test/unit'
require 'webrick'

class IntegrationTest < Test::Unit::TestCase
  def setup
    @server = WEBrick::HTTPServer.new(:Port => '1234', :Logger => WEBrick::Log.new("/dev/null"), :AccessLog => [])
    @requests = []
    @server.mount_proc '/murmurs' do |req, res|
      @requests << {:body => req.body,
        :content_length => req.content_length,
        :content_type => req.content_type}
    end
    Thread.start do
      @server.start
    end
    @test_dir = '/tmp/murmurs_itest'
    @base_dir = File.expand_path(File.dirname(__FILE__) + '/..')
    FileUtils.mkdir(@test_dir)
  end

  def teardown
    @server.shutdown
    FileUtils.rm_rf @test_dir
  end

  def test_git_hook
    install_murmurs_gem
    create_git_repositories
    install_hook
    git_push
    assert_equal 3, @requests.size
    assert_match /hello world 0/, @requests[0][:body]
    assert_match /hello world 1/, @requests[1][:body]
    assert_match /hello world 2/, @requests[2][:body]
  end

  def install_murmurs_gem
    Dir.chdir(@base_dir) do
      exec "rm -rf murmurs-*"
      exec "gem build murmurs.gemspec"
    end
    Dir.chdir(@test_dir) do
      exec "gem install #{@base_dir}/murmurs-*"
    end
  end

  def install_hook
    origin = File.join(@test_dir, 'origin')
    Dir.chdir(@test_dir) do
      exec "murmurs -a #{origin}"
    end
    Dir.chdir(origin) do
      exec 'git config hooks.minglemurmursurl "http://localhost:1234/murmurs"'
      exec "git config hooks.mingleaccesskeyid key_id"
      exec "git config hooks.mingleaccesssecretkey SECRET"
    end
  end

  def create_git_repositories
    Dir.chdir(@test_dir) do
      exec "mkdir origin"
      Dir.chdir(File.join(@test_dir, 'origin')) do
        exec "git init --bare"
      end
      exec "git clone origin client"
    end
  end

  def git_push
    Dir.chdir(File.join(@test_dir, 'client')) do
      exec "git commit --allow-empty -m 'hello world 0'"
      exec "git commit --allow-empty -m 'hello world 1'"
      exec "git commit --allow-empty -m 'hello world 2'"
      exec "git push origin master"
    end
  end

  def exec(cmd)
    puts `#{cmd}`
  end
end
