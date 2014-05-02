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
end
