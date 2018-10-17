
describe SwiftypeAppSearch::Client do
  let(:engine_name) { "ruby-client-test-#{Time.now.to_i}" }

  include_context "App Search Credentials"
  let(:client) { SwiftypeAppSearch::Client.new(client_options) }

  describe 'Requests' do
    it 'should include client name and version in headers' do
      stub_request(:any, "#{client_options[:host_identifier]}.api.swiftype.com/api/as/v1/engines")
      client.list_engines
      expect(WebMock).to have_requested(:get, "https://#{client_options[:host_identifier]}.api.swiftype.com/api/as/v1/engines").
        with(
          headers: {
            'X-Swiftype-Client' => 'swiftype-app-search-ruby',
            'X-Swiftype-Client-Version' => SwiftypeAppSearch::VERSION
          }
        )
    end
  end

  context 'Documents' do
    let(:document) { { 'url' => 'http://www.youtube.com/watch?v=v1uyQZNg2vE' } }

    before do
      client.create_engine(engine_name) rescue SwiftypeAppSearch::BadRequest
    end

    after do
      client.destroy_engine(engine_name) rescue SwiftypeAppSearch::NonExistentRecord
    end

    describe '#index_document' do
      subject { client.index_document(engine_name, document) }

      it 'should return a processed document status hash' do
        expect(subject).to match('id' => anything)
      end

      context 'when the document has an id' do
        let(:id) { 'some_id' }
        let(:document) { { 'id' => id, 'url' => 'http://www.youtube.com/watch?v=v1uyQZNg2vE' } }

        it 'should return a processed document status hash with the same id' do
          expect(subject).to eq('id' => id)
        end
      end

      context 'when a document has processing errors' do
        let(:document) { { 'id' => 'too long' * 100 } }

        it 'should raise an error when the API returns errors in the response' do
          expect do
            subject
          end.to raise_error(SwiftypeAppSearch::InvalidDocument, /Invalid field/)
        end
      end

      context 'when a document has a Ruby Time object' do
        let(:time_rfc3339) { '2018-01-01T01:01:01+00:00' }
        let(:time_object) { Time.parse(time_rfc3339) }
        let(:document) { { 'created_at' => time_object } }

        it 'should serialize the time object in RFC 3339' do
          response = subject
          expect(response).to have_key('id')
          document_id = response.fetch('id')
          expect do
            documents = client.get_documents(engine_name, [document_id])
            expect(documents.size).to eq(1)
            expect(documents.first['created_at']).to eq(time_rfc3339)
          end.to_not raise_error
        end
      end
    end

    describe '#index_documents' do
      let(:documents) { [document, second_document] }
      let(:second_document_id) { 'another_id' }
      let(:second_document) { { 'id' => second_document_id, 'url' => 'https://www.youtube.com/watch?v=9T1vfsHYiKY' } }
      subject { client.index_documents(engine_name, documents) }

      it 'should return an array of document status hashes' do
        expect(subject).to match([
          { 'id' => anything, 'errors' => [] },
          { 'id' => second_document_id, 'errors' => [] }
        ])
      end

      context 'when one of the documents has processing errors' do
        let(:second_document) { { 'id' => 'too long' * 100 } }

        it 'should return respective errors in an array of document processing hashes' do
          expect(subject).to match([
            { 'id' => anything, 'errors' => [] },
            { 'id' => anything, 'errors' => ['Invalid field type: id must be less than 800 characters'] },
          ])
        end
      end
    end

    describe '#update_documents' do
      let(:documents) { [document, second_document] }
      let(:second_document_id) { 'another_id' }
      let(:second_document) { { 'id' => second_document_id, 'url' => 'https://www.youtube.com/watch?v=9T1vfsHYiKY' } }
      let(:updates) { [ {
        'id' => second_document_id,
        'url' => 'https://www.example.com'
      } ] }

      subject { client.update_documents(engine_name, updates) }

      before do
        client.index_documents(engine_name, documents)
      end

      # Note that since indexing a document takes up to a minute,
      # we don't expect this to succeed, so we simply verify that
      # the request responded with the correct 'id', even though
      # the 'errors' object likely contains errors.
      it 'should update existing documents' do
        response = subject
        expect(subject).to match(['id' => second_document_id, 'errors' => anything])
      end
    end

    describe '#get_documents' do
      let(:documents) { [first_document, second_document] }
      let(:first_document_id) { 'id' }
      let(:first_document) { { 'id' => first_document_id, 'url' => 'https://www.youtube.com/watch?v=v1uyQZNg2vE' } }
      let(:second_document_id) { 'another_id' }
      let(:second_document) { { 'id' => second_document_id, 'url' => 'https://www.youtube.com/watch?v=9T1vfsHYiKY' } }

      subject { client.get_documents(engine_name, [first_document_id, second_document_id]) }

      before do
        client.index_documents(engine_name, documents)
      end

      it 'will return documents by id' do
        response = subject
        expect(response.size).to eq(2)
        expect(response[0]['id']).to eq(first_document_id)
        expect(response[1]['id']).to eq(second_document_id)
      end
    end

    describe '#list_documents' do
      let(:documents) { [first_document, second_document] }
      let(:first_document_id) { 'id' }
      let(:first_document) { { 'id' => first_document_id, 'url' => 'https://www.youtube.com/watch?v=v1uyQZNg2vE' } }
      let(:second_document_id) { 'another_id' }
      let(:second_document) { { 'id' => second_document_id, 'url' => 'https://www.youtube.com/watch?v=9T1vfsHYiKY' } }

      before do
        client.index_documents(engine_name, documents)
      end

      context 'when no options are specified' do
        it 'will return all documents' do
          response = client.list_documents(engine_name)
          expect(response['results'].size).to eq(2)
          expect(response['results'][0]['id']).to eq(first_document_id)
          expect(response['results'][1]['id']).to eq(second_document_id)
        end
      end

      context 'when options are specified' do
        it 'will return all documents' do
          response = client.list_documents(engine_name, {page: { size: 1, current: 2}})
          expect(response['results'].size).to eq(1)
          expect(response['results'][0]['id']).to eq(second_document_id)
        end
      end
    end
  end

  context 'Search' do
    # Note that since indexing a document takes up to a minute,
    # don't actually expect results to be present, just that
    # the request was made

    before do
      client.create_engine(engine_name) rescue SwiftypeAppSearch::BadRequest
    end

    after do
      client.destroy_engine(engine_name) rescue SwiftypeAppSearch::NonExistentRecord
    end

    describe '#search' do
      subject { client.search(engine_name, query, options) }
      let (:query) { '' }
      let (:options) { { 'page' => { 'size' => 1 } } }

      it 'should execute a search query' do
        response = subject
        expect(response).to have_key('meta')
        expect(response).to have_key('results')
      end
    end

    describe '#multi_search' do
      subject { client.multi_search(engine_name, queries) }

      context 'when options are provided' do
        let (:queries) { [
          {'query': 'foo', 'options' => { 'page' => { 'size' => 1 } }},
          {'query': 'bar', 'options' => { 'page' => { 'size' => 1 } }}
        ] }

        it 'should execute a multi search query' do
          response = subject
          expect(response.size).to eq(2)
          expect(response[0]).to have_key('results')
          expect(response[0]).to have_key('meta')
          expect(response[1]).to have_key('results')
          expect(response[1]).to have_key('meta')
        end
      end

      context 'when options are omitted' do
        let (:queries) { [
          {'query': 'foo' },
          {'query': 'bar' }
        ] }

        it 'should execute a multi search query' do
          response = subject
          expect(response.size).to eq(2)
          expect(response[0]).to have_key('results')
          expect(response[0]).to have_key('meta')
          expect(response[1]).to have_key('results')
          expect(response[1]).to have_key('meta')
        end
      end
    end
  end

  context 'Engines' do
    after do
      client.destroy_engine(engine_name) rescue SwiftypeAppSearch::NonExistentRecord
    end

    context '#create_engine' do
      it 'should create an engine when given a right set of parameters' do
        expect { client.get_engine(engine_name) }.to raise_error(SwiftypeAppSearch::NonExistentRecord)
        client.create_engine(engine_name)
        expect { client.get_engine(engine_name) }.to_not raise_error
      end

      it 'should return an engine object' do
        engine = client.create_engine(engine_name)
        expect(engine).to be_kind_of(Hash)
        expect(engine['name']).to eq(engine_name)
      end

      it 'should return an error when the engine name has already been taken' do
        client.create_engine(engine_name)
        expect { client.create_engine(engine_name) }.to raise_error do |e|
          expect(e).to be_a(SwiftypeAppSearch::BadRequest)
          expect(e.errors).to eq(['Name is already taken'])
        end
      end
    end

    context '#list_engines' do
      it 'should return an array with a list of engines' do
        expect(client.list_engines['results']).to be_an(Array)
      end

      it 'should include the engine name in listed objects' do
        client.create_engine(engine_name)

        engines = client.list_engines['results']
        expect(engines.find { |e| e['name'] == engine_name }).to_not be_nil
      end

      it 'should include the engine name in listed objects with pagination' do
        client.create_engine(engine_name)

        engines = client.list_engines(:current => 1, :size => 20)['results']
        expect(engines.find { |e| e['name'] == engine_name }).to_not be_nil
      end
    end

    context '#destroy_engine' do
      it 'should destroy the engine if it exists' do
        client.create_engine(engine_name)
        expect { client.get_engine(engine_name) }.to_not raise_error

        client.destroy_engine(engine_name)
        expect { client.get_engine(engine_name) }.to raise_error(SwiftypeAppSearch::NonExistentRecord)
      end

      it 'should raise an error if the engine does not exist' do
        expect { client.destroy_engine(engine_name) }.to raise_error(SwiftypeAppSearch::NonExistentRecord)
      end
    end
  end

  context 'Configuration' do
    context 'host_identifier' do
      it 'sets the base url correctly' do
        client = SwiftypeAppSearch::Client.new(:host_identifier => 'host-asdf', :api_key => 'foo')
        expect(client.api_endpoint).to eq('https://host-asdf.api.swiftype.com/api/as/v1/')
      end

      it 'sets the base url correctly using deprecated as_host_key' do
        client = SwiftypeAppSearch::Client.new(:account_host_key => 'host-asdf', :api_key => 'foo')
        expect(client.api_endpoint).to eq('https://host-asdf.api.swiftype.com/api/as/v1/')
      end
    end
  end
end
