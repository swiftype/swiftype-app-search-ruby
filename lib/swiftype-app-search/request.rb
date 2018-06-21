require 'net/https'
require 'json'
require 'time'
require 'swiftype-app-search/exceptions'
require 'swiftype-app-search/version'
require 'openssl'

module SwiftypeAppSearch
  DEFAULT_USER_AGENT = "swiftype-app-search-ruby/#{SwiftypeAppSearch::VERSION}"

  module Request
    attr_accessor :last_request

    def get(path, params={})
      request(:get, path, params)
    end

    def post(path, params={})
      request(:post, path, params)
    end

    def put(path, params={})
      request(:put, path, params)
    end

    def patch(path, params={})
      request(:patch, path, params)
    end

    def delete(path, params={})
      request(:delete, path, params)
    end

    # Construct and send a request to the API.
    #
    # @raise [Timeout::Error] when the timeout expires
    def request(method, path, params = {})
      Timeout.timeout(overall_timeout) do
        uri = URI.parse("#{api_endpoint}#{path}")

        request = build_request(method, uri, params)
        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = open_timeout
        http.read_timeout = overall_timeout

        http.set_debug_output(STDERR) if debug?

        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.ca_file = File.join(File.dirname(__FILE__), '..', 'data', 'ca-bundle.crt')
          http.ssl_timeout = open_timeout
        end

        @last_request = request

        response = http.request(request)
        response_json = parse_response(response)

        case response
        when Net::HTTPSuccess
          return response_json
        when Net::HTTPBadRequest
          raise SwiftypeAppSearch::BadRequest, response_json
        when Net::HTTPUnauthorized
          raise SwiftypeAppSearch::InvalidCredentials, response_json
        when Net::HTTPNotFound
          raise SwiftypeAppSearch::NonExistentRecord, response_json
        when Net::HTTPForbidden
          raise SwiftypeAppSearch::Forbidden, response_json
        when Net::HTTPRequestEntityTooLarge
          raise SwiftypeAppSearch::RequestEntityTooLarge, response_json
        else
          raise SwiftypeAppSearch::UnexpectedHTTPException.new(response, response_json)
        end
      end
    end

    private

    def parse_response(response)
      body = response.body.to_s.strip
      body == '' ? {} : JSON.parse(body)
    end

    def debug?
      @debug ||= (ENV['AS_DEBUG'] == 'true')
    end

    def serialize_json(object)
      JSON.generate(clean_json(object))
    end

    def clean_json(object)
      case object
      when Hash
        object.inject({}) do |builder, (key, value)|
          builder[key] = clean_json(value)
          builder
        end
      when Enumerable
        object.map { |value| clean_json(value) }
      else
        clean_atom(object)
      end
    end

    def clean_atom(atom)
      if atom.is_a?(Time)
        atom.to_datetime
      else
        atom
      end
    end

    def build_request(method, uri, params)
      klass = case method
              when :get
                Net::HTTP::Get
              when :post
                Net::HTTP::Post
              when :put
                Net::HTTP::Put
              when :patch
                Net::HTTP::Patch
              when :delete
                Net::HTTP::Delete
              end

      req = klass.new(uri.request_uri)
      req.body = serialize_json(params) unless params.length == 0

      req['User-Agent'] = DEFAULT_USER_AGENT
      req['Content-Type'] = 'application/json'
      req['Authorization'] = "Bearer #{api_key}"

      req
    end
  end
end
