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

    it 'gets a list' do
      expect(HTTParty).to receive(:get).with("#{server}/api/v2/streams", {headers: headers, body: nil} )
      subject.streams
    end

    it 'uploads' do
      body = 'something'
      expect(HTTParty).to receive(:post).with("#{server}/api/v2/streams", {headers: headers, body: body} )
      subject.upload_stream body
    end

  end

end
