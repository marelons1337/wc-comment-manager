class WooCommerceAPI
  class Response
    def initialize(http_response)
      @http_response = http_response
    end

    def parsed_response
      JSON.parse(@http_response.body)
    end

    def code
      @http_response.code.to_i
    end
  end

  def initialize(url, consumer_key, consumer_secret, options = {})
    @url = url
    @consumer_key = consumer_key
    @consumer_secret = consumer_secret

    version = options[:version] || 'wc/v1'
    @url = "#{url}/wp-json/#{version}/"
  end

  def get(endpoint, options = {})
    uri = URI.join(@url, endpoint)
    uri.query = URI.encode_www_form(options[:params]) if options[:params]
    req = Net::HTTP::Get.new(uri)
    req.basic_auth @consumer_key, @consumer_secret

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http|
      http.request(req)
    }

    Response.new(res)
  end

  def post(endpoint, data)
    uri = URI.join(@url, endpoint)
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.basic_auth @consumer_key, @consumer_secret
    req.body = data.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http|
      http.request(req)
    }

    Response.new(res)
  end
end