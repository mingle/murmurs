require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'
require 'json'
require 'murmurs/git'

module Murmurs
  class Error < StandardError; end
  class InvalidMurmursURLError < Error; end
  class UnexpectedResponseError < Error; end
  class HookExistsError < Error; end

  include Git

  def murmur(url, msg, options={})
    if msg.nil? || msg.empty?
      log(options[:log_level], "Nothing to murmur.")
      return
    end

    log(options[:log_level], "murmur => #{extract_project_info(url)}")
    if options[:git]
      Array(git_commits(msg, options[:git_branch])).each do |msg|
        murmur(url, msg, options.merge(:git => false, :log_level => :error))
      end
    else
      validate_murmurs_url!(url)
      http_post(url, {:murmur => {:body => msg}}, options)
    end
  end

  def extract_project_info(url)
    if url =~ /\/projects\/([^\/]+)\//
      "#{$1}@#{URI(url).host}"
    else
      url
    end
  end

  def validate_murmurs_url!(url)
    if url.to_s !~ /\Ahttps?\:\/\/.+\/murmurs/
      raise InvalidMurmursURLError, "Invalid murmurs URL: #{url.inspect}"
    end
  end

  def truncate(m, t=15)
    m.size > t ? "#{m[0..t]}..." : m
  end

  def log(level, m)
    if level == :info
      puts m
    end
  end

  def http_post(url, params, options={})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      if options[:skip_ssl_verify]
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
    body = params.to_json

    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = body

    request['Content-Type'] = 'application/json'
    request['Content-Length'] = body.bytesize


    if options[:access_key_id]
      ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])
    end

    response = http.request(request)

    if response.code.to_i > 300
      raise UnexpectedResponseError, <<-ERROR
\nRequest URL: #{url}
Response: #{response.code} #{response.message}
Response Headers: #{response.to_hash.inspect}\nResponse Body: #{response.body}"
ERROR
    end
  end
end
