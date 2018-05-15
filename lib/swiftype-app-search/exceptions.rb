module SwiftypeAppSearch
  class ClientException < StandardError
    attr_reader :errors

    def initialize(response)
      @errors = response['errors'] || [response]
      message = (errors.count == 1) ? "Error: #{errors.first}" : "Errors: #{errors.inspect}"
      super(message)
    end
  end

  class NonExistentRecord < ClientException; end
  class InvalidCredentials < ClientException; end
  class BadRequest < ClientException; end
  class Forbidden < ClientException; end
  class InvalidDocument < ClientException; end
  class RequestEntityTooLarge < ClientException; end

  class UnexpectedHTTPException < ClientException
    def initialize(response, response_body)
      response_body['errors'] = [response.message] unless response_body['errors']
      response_body['errors'].map! { |e| "(#{response.code}) #{e}" }
      super(response_body)
    end
  end
end
