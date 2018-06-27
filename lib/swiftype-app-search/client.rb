require 'set'
require 'swiftype-app-search/request'
require 'swiftype-app-search/utils'
require 'jwt'

module SwiftypeAppSearch
  # API client for the {Swiftype App Search API}[https://swiftype.com/app-search].
  class Client
    autoload :Documents, 'swiftype-app-search/client/documents'
    autoload :Engines, 'swiftype-app-search/client/engines'
    autoload :Search, 'swiftype-app-search/client/search'

    DEFAULT_TIMEOUT = 15

    include SwiftypeAppSearch::Request

    attr_reader :api_key, :open_timeout, :overall_timeout, :api_endpoint

    # Create a new SwiftypeAppSearch::Client client
    #
    # @param options [Hash] a hash of configuration options that will override what is set on the SwiftypeAppSearch class.
    # @option options [String] :account_host_key an Account Host Key to use for this client
    # @option options [String] :api_key an Api Key to use for this client
    # @option options [Numeric] :overall_timeout overall timeout for requests in seconds (default: 15s)
    # @option options [Numeric] :open_timeout the number of seconds Net::HTTP (default: 15s)
    #   will wait while opening a connection before raising a Timeout::Error
    def initialize(options = {})
      @api_endpoint = options.fetch(:api_endpoint) { "https://#{options.fetch(:account_host_key || :host_identifier)}.api.swiftype.com/api/as/v1/" }
      @api_key = options.fetch(:api_key || :private_key)
      @open_timeout = options.fetch(:open_timeout, DEFAULT_TIMEOUT).to_f
      @overall_timeout = options.fetch(:overall_timeout, DEFAULT_TIMEOUT).to_f
    end

    module SignedSearchOptions
      ALGORITHM = 'HS256'.freeze

      module ClassMethods
        # Build a JWT for authentication
        #
        # @param [String] api_key the API Key to sign the request with
        # @param [String] api_key_name the unique name for the API Key
        # @option options see the {App Search API}[https://swiftype.com/documentation/app-search/] for supported search options.
        #
        # @return [String] the JWT to use for authentication
        def create_signed_search_key(api_key, api_key_name, options = {})
          raise 'Must create signed search key with an API Key, cannot use a Search Key' unless api_key.start_with?('api')
          payload = Utils.symbolize_keys(options).merge(:api_key_name => api_key_name)
          JWT.encode(payload, api_key, ALGORITHM)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end

    include SwiftypeAppSearch::Client::Documents
    include SwiftypeAppSearch::Client::Engines
    include SwiftypeAppSearch::Client::Search
    include SwiftypeAppSearch::Client::SignedSearchOptions
  end
end
