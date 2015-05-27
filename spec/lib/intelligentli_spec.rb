describe Intelligentli::Api do

  # request parameters
  let (:server)  { 'http://somewhere' }
  let (:key)     { 'key' }
  let (:secret)  { 'secret' }

  # derived parameters
  let (:time)    { Time.utc(2015, 5, 7) }
  let (:token)   { 'token' }
  let (:headers) {
    {
      'User-key'     => key,
      'User-token'   => token,
      'Date'         => time.httpdate,
      'Content-Type' => 'application/json'
    }
  }

  before do
    Timecop.freeze time
    allow(Gibberish).to receive(:HMAC256).and_return(token)
  end
  after { Timecop.return }

  subject { Intelligentli::Api.new(server, key, secret) }

  context 'watch' do
    let(:uri)             { '/uri' }
    let(:websocket)       { double }
    let(:initial_message) {'{"message_sequence": 0}'}
    let(:message)         { {hello: 'world'} }
    let(:payload)         { {message: message.to_json}.to_json  }
    let(:event)           { double(data: payload) }

    it 'makes websocket request' do
      expect(Faye::WebSocket::Client).to receive(:new).with("#{server}#{uri}", nil, headers: headers, ping: 20).and_return (websocket.as_null_object)
      subject.watch(uri)
    end

    it 'requests for an initial message sequence' do
      allow(Faye::WebSocket::Client).to receive(:new).and_return(websocket)

      allow(websocket).to receive(:on).with(:open).and_yield(event)
      allow(websocket).to receive(:on).with(:message)
      allow(websocket).to receive(:on).with(:close)

      expect(websocket).to receive(:send).with(initial_message)
      subject.watch(uri)
    end

    it 'yields on events' do
      allow(Faye::WebSocket::Client).to receive(:new).and_return(websocket)

      allow(websocket).to receive(:on).with(:open)
      allow(websocket).to receive(:on).with(:message).and_yield(event)
      allow(websocket).to receive(:on).with(:close)

      expect { |b| subject.watch(uri, &b) }.to yield_with_args(message)
    end

    it 'closes the connection' do
      allow(Faye::WebSocket::Client).to receive(:new).and_return(websocket)

      allow(websocket).to receive(:on).with(:open)
      allow(websocket).to receive(:on).with(:message)
      allow(websocket).to receive(:on).with(:close).and_yield(event)

      expect{ subject.watch(uri) }.to raise_error(RuntimeError)
    end

  end
end
