describe SwiftypeAppSearch::Client do
  let(:engine_name) { "ruby-client-test-#{Time.now.to_i}" }

  include_context "App Search Credentials"
  let(:client) { SwiftypeAppSearch::Client.new(:account_host_key => as_account_host_key, :api_key => as_api_key) }

  context 'Documents' do
    let(:document) { { 'url' => 'http://www.youtube.com/watch?v=v1uyQZNg2vE' } }
    let(:documents) { [document] }

    describe '#index_document' do
      it 'should validate required document fields' do
        expect do
          client.index_document(engine_name, document)
        end.to raise_error(SwiftypeAppSearch::InvalidDocument, 'Error: missing required fields (id)')
      end

      context 'with an invalid document that passes client checks' do
        let(:document) { { 'id' => 1, 'bad' => { 'no' => 'nested hashes' } } }

        it 'should raise an error when the API returns errors in the response' do
          expect do
            client.index_document(engine_name, document)
          end.to raise_error(SwiftypeAppSearch::InvalidDocument, /Invalid field value/)
        end
      end
    end

    describe '#index_documents' do
      it 'should validate required document fields' do
        expect do
          client.index_documents(engine_name, documents)
        end.to raise_error(SwiftypeAppSearch::InvalidDocument, 'Error: missing required fields (id)')
      end
    end
  end

  context 'Engines' do
    after do
      # Clean up the test engine from our account
      begin
        client.destroy_engine(engine_name)
      rescue SwiftypeAppSearch::NonExistentRecord
      end
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
        expect(client.list_engines).to be_an(Array)
      end

      it 'should include the engine name in listed objects' do
        # Create an engine
        client.create_engine(engine_name)

        # Get the list
        engines = client.list_engines
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
    context 'account_host_key' do
      it 'sets the base url correctly' do
        client = SwiftypeAppSearch::Client.new(:account_host_key => 'host-asdf', :api_key => 'foo')
        expect(client.api_endpoint).to eq('https://host-asdf.api.swiftype.com/api/as/v1/')
      end
    end
  end
end
