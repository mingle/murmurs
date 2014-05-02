require 'net/http'
require 'net/https'
require 'time'
require 'api-auth'

module Murmurs
  def murmur(url, msg, options={})
    if options[:git]
      msg = git_commits_murmur(msg, options[:git_branch])
    end

    if url.to_s !~ /\Ahttps?\:\/\/.+\/projects\/[^\/]+\/murmurs/
      raise "Invalid murmurs URL: #{url.inspect}"
    end
    if msg.nil? || msg.empty?
      puts "Nothing to murmur." unless options[:git]
      return
    end
    t = 20
    Array(msg).each do |m|
      git_log(options[:git], m)
      http_post(url, {'murmur[body]' => m}, options)
    end
  end

  def git_log(log, m)
    if log
      if m.size > t
        puts "murmur #{m[0..t]}..."
      else
        puts "murmur #{m}"
      end
    end
  end

  # input: git post receive stdin string
  # branch: git branch
  def git_commits_murmur(input, branch)
    data = input.split("\n").map do |l|
      l.split
    end.find do |l|
      l[2] =~ /\Arefs\/heads\/#{branch}\z/
    end

    return if data.nil?

    null_rev = '0' * 40
    from_rev, to_rev, _ = data
    if to_rev == null_rev # delete branch
      "Someone deleted branch #{branch}."
    else
      revs = if from_rev == null_rev  # new branch
               to_rev
             else
               "#{from_rev}..#{to_rev}"
             end
      `git rev-list #{revs}`.split("\n").map do |rev|
        `git log -n 1 #{rev}`
      end
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

    request = Net::HTTP::Post.new(uri.request_uri)
    request.form_data = params if params

    if options[:access_key_id]
      ApiAuth.sign!(request, options[:access_key_id], options[:access_secret_key])
    end

    response = http.request(request)

    if response.code.to_i > 300
      response.error!
    end
  end
end
