require 'net/http'
require 'net/https'

require 'api-auth'

module Murmurs
  def murmur(url, msg, options={})
    if url.to_s !~ /\Ahttps?\:\/\/.+\/projects\/[^\/]+\/murmurs/
      raise "Invalid murmurs URL: #{url.inspect}"
    end
    http_post(url, {'murmur[body]' => msg}, options)
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
      raise "error[#{request_class.name}][#{url}][#{response.code}]:\n#{response.body}"
    end
  end
end
