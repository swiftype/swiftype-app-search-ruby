require 'bundler/setup'
require 'rspec'
require 'webmock/rspec'
require 'awesome_print'
require 'swiftype-app-search'
require 'config_helper'

WebMock.allow_net_connect!

RSpec.shared_context 'App Search Credentials' do
  let(:as_api_key) { ConfigHelper.get_as_api_key }
  # AS_ACCOUNT_HOST_KEY is deprecated
  let(:as_host_identifier) { ConfigHelper.get_as_host_identifier }
  let(:as_api_endpoint) { ConfigHelper.get_as_api_endpoint }
  let(:client_options) do
    ConfigHelper.get_client_options(as_api_key, as_host_identifier, as_api_endpoint)
  end
end

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
