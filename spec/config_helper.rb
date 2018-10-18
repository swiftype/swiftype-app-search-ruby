module ConfigHelper
  def ConfigHelper.get_as_api_key
    ENV.fetch('AS_API_KEY', 'API_KEY')
  end

  def ConfigHelper.get_as_host_identifier
    ENV['AS_ACCOUNT_HOST_KEY'] || ENV['AS_HOST_IDENTIFIER'] || 'ACCOUNT_HOST_KEY'
  end

  def ConfigHelper.get_as_api_endpoint
    ENV.fetch('AS_API_ENDPOINT', nil)
  end

  def ConfigHelper.get_client_options(as_api_key, as_host_identifier, as_api_endpoint)
    {
      :api_key => as_api_key,
      :host_identifier => as_host_identifier
    }.tap do |opts|
      opts[:api_endpoint] = as_api_endpoint unless as_api_endpoint.nil?
    end
  end
end
