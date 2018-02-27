module SwiftypeAppSearch
  class Client
    module Search
      # Search for documents
      #
      # @param [String] engine_name the unique Engine name
      # @param [String] query the search query
      # @option options see the {App Search API}[https://swiftype.com/documentation/app-search/] for supported search options.
      #
      # @return [Array<Hash>] an Array of Document destroy result hashes
      def search(engine_name, query, options = {})
        params = Utils.symbolize_keys(options).merge(:query => query)
        request(:post, "engines/#{engine_name}/search", params)
      end
    end
  end
end
