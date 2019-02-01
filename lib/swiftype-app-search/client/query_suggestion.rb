module SwiftypeAppSearch
  class Client
    module QuerySuggestion
      # Request Query Suggestions
      #
      # @param [String] engine_name the unique Engine name
      # @param [String] query the search query to suggest for
      # @options options see the {App Search API}[https://swiftype.com/documentation/app-search/] for supported search options.
      #
      # @return [Hash] search results
      def query_suggestion(engine_name, query, options = {})
        params = Utils.symbolize_keys(options).merge(:query => query)
        request(:post, "engines/#{engine_name}/query_suggestion", params)
      end
    end
  end
end
