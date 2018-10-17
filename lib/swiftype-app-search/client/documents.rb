# Documents have fields that can be searched or filtered.
#
# For more information on indexing documents, see the {App Search documentation}[https://swiftype.com/documentation/app-search/].
module SwiftypeAppSearch
  class Client
    module Documents

      # Retrieve all Documents from the API for the {App Search API}[https://swiftype.com/documentation/app-search/]
      #
      # @param [String] engine_name the unique Engine names
      # @option options see the {App Search API}[https://swiftype.com/documentation/app-search/] for supported options.
      #
      # @return [Array<Hash>] an Array of Documents
      def list_documents(engine_name, options = {})
        params = Utils.symbolize_keys(options)
        request(:get, "engines/#{engine_name}/documents/list", params)
      end

      # Retrieve Documents from the API by IDs for the {App Search API}[https://swiftype.com/documentation/app-search/]
      #
      # @param [String] engine_name the unique Engine name
      # @param [Array<String>] ids an Array of Document IDs
      #
      # @return [Hash] list results
      def get_documents(engine_name, ids)
        get("engines/#{engine_name}/documents", ids)
      end

      # Index a document using the {App Search API}[https://swiftype.com/documentation/app-search/].
      #
      # @param [String] engine_name the unique Engine name
      # @param [Array] document a Document Hash
      #
      # @return [Hash] processed Document Status hash
      #
      # @raise [SwiftypeAppSearch::InvalidDocument] when the document has processing errors returned from the api
      # @raise [Timeout::Error] when timeout expires waiting for statuses
      def index_document(engine_name, document)
        response = index_documents(engine_name, [document])
        errors = response.first['errors']
        raise InvalidDocument.new(errors.join('; ')) if errors.any?
        response.first.tap { |h| h.delete('errors') }
      end

      # Index a batch of documents using the {App Search API}[https://swiftype.com/documentation/app-search/].
      #
      # @param [String] engine_name the unique Engine name
      # @param [Array] documents an Array of Document Hashes
      #
      # @return [Array<Hash>] an Array of processed Document Status hashes
      #
      # @raise [SwiftypeAppSearch::InvalidDocument] when any documents have processing errors returned from the api
      # @raise [Timeout::Error] when timeout expires waiting for statuses
      def index_documents(engine_name, documents)
        documents.map! { |document| normalize_document(document) }
        post("engines/#{engine_name}/documents", documents)
      end

      # Destroy a batch of documents given a list of IDs
      #
      # @param [Array<String>] ids an Array of Document IDs
      #
      # @return [Array<Hash>] an Array of Document destroy result hashes
      def destroy_documents(engine_name, ids)
        delete("engines/#{engine_name}/documents", ids)
      end

      private

      def normalize_document(document)
        Utils.stringify_keys(document)
      end
    end
  end
end
