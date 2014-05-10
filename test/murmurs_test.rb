require 'test/unit'
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'murmurs'
require 'webrick'

class MurmursTest < Test::Unit::TestCase
  include Murmurs

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
  end

  def teardown
    @server.shutdown
  end

  def test_murmur
    murmur('http://localhost:1234/murmurs', "hello world")
    assert_equal 1, @requests.size
    req = @requests.first
    assert_equal "{\"murmur\":{\"body\":\"hello world\"}}", req[:body]
    assert_equal "application/json", req[:content_type]
    assert_equal 33, req[:content_length]
  end

  def test_validate_murmurs_url
    assert_raise InvalidMurmursURLError do
      murmur('http://localhost:1234/haha', 'hello')
    end
    assert_raise InvalidMurmursURLError do
      murmur('', 'hello')
    end
    assert_raise InvalidMurmursURLError do
      murmur(nil, 'hello')
    end
  end

  def test_murmur_git_commits
    murmur('http://localhost:1234/murmurs', <<-GIT_INPUT, :git => true, :git_branch => 'master', :log_level => :error)
886aa9a26fcd4976268de94135e7c00fbe35f9c1 d91bab265eac6f7c46f2249910f2e8a51439fa3a refs/heads/master
invalid 1 refs/heads/wrong
GIT_INPUT

    assert_equal 5, @requests.size

    m1 = {
      :body => "{\"murmur\":{\"body\":\"Author: Xiao Li <swing1979@gmail.com>\\n\\nadd -g and -b options to murmur git changes from git post-receive hook stdin\\n\\ncommit murmurs:ff0fbd52\\nDate:   Thu May 1 20:51:07 2014 -0700\\n\"}}",
      :content_length => 207,
      :content_type => "application/json"
    }
    assert_equal(m1, @requests[0])
    m5 = {
      :body => "{\"murmur\":{\"body\":\"Author: Xiao Li <swing1979@gmail.com>\\n\\nadd license and update authors name\\n\\ncommit murmurs:91bab265\\nDate:   Fri May 2 07:46:16 2014 -0700\\n\"}}",
      :content_length => 166,
      :content_type => "application/json"
    }
    assert_equal(m5, @requests[4])
  end

  def test_murmur_nothing
    murmur('http://localhost:1234/murmurs', nil)
    murmur('http://localhost:1234/murmurs', '')

    murmur('http://localhost:1234/murmurs', <<-GIT_INPUT, :git => true, :git_branch => 'master', :log_level => :error)
886aa9a26fcd4976268de94135e7c00fbe35f9c1 d91bab265eac6f7c46f2249910f2e8a51439fa3a refs/heads/branch
GIT_INPUT

    assert_equal 0, @requests.size
  end

  def test_extract_project_info
    assert_equal 'proj@host', extract_project_info('https://host/api/v2/projects/proj/murmurs.xml')
  end

  def test_http_post_error_handling
    assert_raise Murmurs::UnexpectedResponseError do
      http_post('https://n-o-tsddfs.mingle.thoughtworks.com', {})
    end
  end

end
