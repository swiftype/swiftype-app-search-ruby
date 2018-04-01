# Ruby client for the Swiftype App Search API

**Note: Swiftype App Search is currently in beta**

## Installation

To install the gem, execute:

```bash
gem install swiftype-app-search
```

Or place `gem 'swiftype-app-search', '~> 0.1.0` in your `Gemfile` and run `bundle install`.

## Usage

### Setup: Configuring the client and authentication

Create a new instance of the Swiftype App Search Client. This requires your `ACCOUNT_HOST_KEY`, which
identifies the unique hostname of the Swiftype API that is associated with your Swiftype account.
It also requires a valid `API_KEY`, which authenticates requests to the API:

```ruby
client = SwiftypeAppSearch::Client.new(account_host_key: 'host-c5s2mj', api_key: 'api-mu75psc5egt9ppzuycnc2mc3')
```

### Indexing Creating or Updating a Single Document

```ruby
engine_name = 'favorite-videos'
document = {
  id: 'INscMGmhmX4',
  url: 'https://www.youtube.com/watch?v=INscMGmhmX4',
  title: 'The Original Grumpy Cat',
  body: 'A wonderful video of a magnificent cat.'
}

begin
  client.index_document(engine_name, document)
rescue SwiftypeAppSearch::ClientException => e
  # handle error
end
```

### Indexing: Creating or Updating Documents

```ruby
engine_name = 'favorite-videos'
documents = [
  {
    id: 'INscMGmhmX4',
    url: 'https://www.youtube.com/watch?v=INscMGmhmX4',
    title: 'The Original Grumpy Cat',
    body: 'A wonderful video of a magnificent cat.'
  },
  {
    id: 'JNDFojsd02',
    url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    title: 'Another Grumpy Cat',
    body: 'A great video of another cool cat.'
  }
]

begin
  index_document_results = client.index_documents(engine_name, documents)
  # handle index document results
rescue SwiftypeAppSearch::ClientException => e
  # handle error
end
```

### Listing Documents

```ruby
engine_name = 'favorite-videos'
document_ids = ['INscMGmhmX4', 'JNDFojsd02']

begin
  document_contents = client.get_documents(engine_name, document_ids)
  # handle document contents
rescue SwiftypeAppSearch::ClientException => e
  # handle error
end
```

### Destroying Documents

```ruby
engine_name = 'favorite-videos'
document_ids = ['INscMGmhmX4', 'JNDFojsd02']

begin
  destroy_document_results = client.destroy_documents(engine_name, document_ids)
  # handle destroy document results
rescue SwiftypeAppSearch::ClientException => e
  # handle error
end
```

### Searching

```ruby
engine_name = 'favorite-videos'
query = 'cat'
search_fields = { title: {} }
result_fields = { title: { raw: {} } }
options = { search_fields: search_fields, result_fields: result_fields }

begin
  search_results = client.search(engine_name, query, options)
  # handle search results
rescue SwiftypeAppSearch::ClientException => e
  # handle error
end
```

## Running Tests

```bash
export AS_API_KEY="your API key"
export AS_ACCOUNT_HOST_KEY="your account host key"
rspec
```

## Debugging API calls

If you need to debug an API call made by the client, there are a few things you could do:

1.  Setting `AS_DEBUG` environment variable to `true` would enable HTTP-level debugging and you would
    see all requests generated by the client on your console.

2.  You could use our API logs feature in App Search console to see your requests and responses live.

3.  In your debug logs you could find a `X-Request-Id` header value. That could be used when talking
    to Swiftype Customer Support to help us quickly find your API request and help you troubleshoot
    your issues.

## Contributions

To contribute code to this gem, please fork the repository and submit a pull request.
