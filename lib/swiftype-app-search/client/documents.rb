# Documents have fields that can be searched or filtered.
#
# For more information on indexing documents, see the {App Search documentation}[https://swiftype.com/documentation/app-search/].
module SwiftypeAppSearch
  class Client
    module Documents
      REQUIRED_TOP_LEVEL_KEYS = [
        'id'
      ].map!(&:freeze).to_set.freeze

      # Retrieve Documents from the API by IDs for the {App Search API}[https://swiftype.com/documentation/app-search/]
      #
      # @param [String] engine_name the unique Engine name
      # @param [Array<String>] ids an Array of Document IDs
      #
      # @return [Array<Hash>] an Array of Documents

      def get_documents(engine_name, ids)
        get("engines/#{engine_name}/documents", ids)
      end

      # Index a batch of documents using the {App Search API}[https://swiftype.com/documentation/app-search/].
      #
      # @param [String] engine_name the unique Engine name
      # @param [Array] documents an Array of Document Hashes
      #
      # @return [Array<Hash>] an Array of processed Document Status hashes
      #
      # @raise [SwiftypeAppSearch::InvalidDocument] when a single document is missing required fields or contains unsupported fields
      # @raise [Timeout::Error] when timeout expires waiting for statuses
      def index_documents(engine_name, documents)
        documents.map! { |document| validate_and_normalize_document(document) }
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
      def validate_and_normalize_document(document)
        document = Utils.stringify_keys(document)
        document_keys = document.keys.to_set
        missing_keys = REQUIRED_TOP_LEVEL_KEYS - document_keys
        raise InvalidDocument.new("missing required fields (#{missing_keys.to_a.join(', ')})") if missing_keys.any?

        document
      end
    end
  end
end
