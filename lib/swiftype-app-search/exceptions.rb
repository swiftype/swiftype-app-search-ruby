module SwiftypeAppSearch
  class ClientException < StandardError
    attr_reader :errors

    def initialize(response)
      @errors = response['errors'] || [ response ]
      message = (errors.count == 1) ? "Error: #{errors.first}" : "Errors: #{errors.inspect}"
      super(message)
    end
  end

  class NonExistentRecord < ClientException; end
  class InvalidCredentials < ClientException; end
  class BadRequest < ClientException; end
  class Forbidden < ClientException; end
  class InvalidDocument < ClientException; end

  class UnexpectedHTTPException < ClientException
    def initialize(http_response)
      @errors = []
      super("HTTP #{http_response.code}: #{http_response.body}")
    end
  end
end
