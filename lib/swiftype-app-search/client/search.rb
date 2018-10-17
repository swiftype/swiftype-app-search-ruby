module SwiftypeAppSearch
  class Client
    module Search
      # Search for documents
      #
      # @param [String] engine_name the unique Engine name
      # @param [String] query the search query
      # @option options see the {App Search API}[https://swiftype.com/documentation/app-search/] for supported search options.
      #
      # @return [Hash] search results
      def search(engine_name, query, options = {})
        params = Utils.symbolize_keys(options).merge(:query => query)
        request(:post, "engines/#{engine_name}/search", params)
      end

      # Run multiple searches for documents on a single request
      #
      # @param [String] engine_name the unique Engine name
      # @param [{query: String, options: Hash}] searches to execute
      # see the {App Search API}[https://swiftype.com/documentation/app-search/] for supported search options.
      #
      # @return [Array<Hash>] an Array of searh sesults
      def multi_search(engine_name, searches)
        params = searches.map do |search|
          search = Utils.symbolize_keys(search)
          query = search[:query]
          options = search[:options] || {}
          Utils.symbolize_keys(options).merge(:query => query)
        end
        request(:post, "engines/#{engine_name}/multi_search", {
          queries: params
        })
      end
    end
  end
end
