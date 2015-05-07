describe Intelligentli do

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

  subject { Intelligentli.new(server, key, secret) }

  context 'streams' do
    let (:response) { double body: {}.to_json }

    it 'gets a list' do
      expect(HTTParty).to receive(:get)
        .with("#{server}/api/v2/streams", {headers: headers, body: nil} )
        .and_return(response)
      subject.streams
    end

    it 'uploads' do
      body = {some: 'body'}
      expect(HTTParty).to receive(:post)
        .with("#{server}/api/v2/streams", {headers: headers, body: body.to_json} )
        .and_return(response)
      subject.upload_stream body
    end
  end

  context 'watch' do
    let(:uri)             { '/uri' }
    let(:websocket)       { double }
    let(:initial_message) {'{"message_sequence": 0}'}
    let(:message)         { {hello: 'world'} }
    let(:payload)         { {message: message.to_json}.to_json  }
    let(:event)           { double(data: payload) }

    it 'makes websocket request' do
      expect(Faye::WebSocket::Client).to receive(:new).with("#{server}#{uri}", nil, headers: headers).and_return (websocket.as_null_object)
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

      subject.watch(uri)
      expect(websocket.instance_variable_get(:@name)).to be_nil
    end

  end
end
