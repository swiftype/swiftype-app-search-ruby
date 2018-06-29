describe SwiftypeAppSearch::Client do
  let(:engine_name) { "ruby-client-test-#{Time.now.to_i}" }

  include_context "App Search Credentials"
  let(:client) { SwiftypeAppSearch::Client.new(client_options) }

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
