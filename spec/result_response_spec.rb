require 'config_helper'

describe SwiftypeAppSearch::ResultResponse do
  subject(:response) { described_class.new(response_json) }
  describe '#each' do
    context 'when the response contains "results"' do
      let(:response_json) do
        {
          'results' => [
            {
              'id' => 'id-01'
            }
          ]
        }
      end

      it 'should enumerate the results' do
        expect(response.map { |r| r['id'] }).to contain_exactly('id-01')
      end
    end

    context 'when the response does not contain "results"' do
      let(:response_json) do
        {
          'id' => 'engine-01',
          'name' => 'new-engine'
        }
      end

      it 'should enumerate the response JSON' do
        expect(response.map { |_, v| v }).to match_array(response_json.values)
      end
    end
  end

  describe '#meta' do
    context 'when the response contains "meta"' do
      let(:response_json) do
        {
          'meta' => {
            'page' => {
              'current' => 1
            }
          }
        }
      end

      it 'should return "meta"' do
        expect(response.meta).to have_key('page')
      end
    end

    context 'when the response does not contain "meta"' do
      let(:response_json) do
        { 'name' => 'engine-name' }
      end

      it 'should return an empty Hash' do
        expect(response.meta).to be_empty
      end
    end
  end
end
