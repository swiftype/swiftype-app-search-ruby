module SwiftypeAppSearch
  class ClientException < StandardError
    attr_reader :errors

    def initialize(response)
      if response.kind_of?(Array)
        @errors = response.map{ |r| r['errors'] }.flatten
      else
        @errors = response['errors'] || [ response ]
      end
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
    def initialize(response, response_json)
      errors = (response_json['errors'] || [response.message]).map { |e| "(#{response.code}) #{e}" }
      super({ 'errors' => errors })
    end
  end
end
