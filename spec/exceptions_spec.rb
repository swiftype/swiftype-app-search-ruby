describe SwiftypeAppSearch::ClientException do
  describe 'when response is a string' do
    let!(:exception) do
      SwiftypeAppSearch::ClientException.new('I am an error')
    end

    it 'it will have the correct message' do
      expect(exception.message).to(eq('Error: I am an error'))
    end
  end

  describe 'when response is hash object with an array of errors' do
    let!(:exception) do
      SwiftypeAppSearch::ClientException.new(
        'errors' => ['I am an error']
      )
    end

    it 'it will have the correct message' do
      expect(exception.message).to(eq('Error: I am an error'))
    end
  end

  describe 'when response is hash object with an array of errors with more than one error' do
    let!(:exception) do
      SwiftypeAppSearch::ClientException.new(
        'errors' => ['I am an error', 'I am another error']
      )
    end

    it 'it will have the correct message' do
      expect(exception.message).to(eq('Errors: ["I am an error", "I am another error"]'))
    end
  end

  describe 'when response is an array with nested responses' do
    let!(:exception) do
      SwiftypeAppSearch::ClientException.new(
        [
          {
            'errors' => ['I am an error']
          },
          {
            'errors' => ['I am another error']
          }
        ]
      )
    end

    it 'it will have the correct message' do
      expect(exception.message).to(eq('Errors: ["I am an error", "I am another error"]'))
    end
  end

  describe 'when response is an array with nested responses and one is a string' do
    let!(:exception) do
      SwiftypeAppSearch::ClientException.new(
        [
          {
            'errors' => ['I am an error']
          },
          "I am another error"
        ]
      )
    end

    it 'it will have the correct message' do
      expect(exception.message).to(eq('Errors: ["I am an error", "I am another error"]'))
    end
  end
end
