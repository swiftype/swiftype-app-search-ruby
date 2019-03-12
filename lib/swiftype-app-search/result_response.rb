# Forwards Ruby Enumerable methods to the :results key of the response for
# endpoints that contain pagination while still maintaining Hash functionality
# Methods like #[] and #[]= will still fall back to Hash-like behavior

class SwiftypeAppSearch::ResultResponse
  include Enumerable

  def initialize(response_json)
    @response_json = response_json

    if @response_json.is_a?(Hash) && @response_json.key?('errors')
      raise SwiftypeAppSearch::ClientException, @response_json
    end
  end

  attr_reader :response_json
  alias_method :json, :response_json

  def results
    return @results if defined?(@results)
    @results = @response_json['results'] if @response_json.is_a?(Hash)
  end

  def meta
    @meta ||= @response_json['meta'].to_h
  end

  def each
    results.nil? ? @response_json.each(&Proc.new) : results.each(&Proc.new)
  end

  def method_missing(symbol, *args, &block)
    @response_json.send(symbol, *args, &block)
  end
end
