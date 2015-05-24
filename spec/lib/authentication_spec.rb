describe Intelligentli::Authentication do

  # request parameters
  let(:key)          { 'key' }
  let(:secret)       { 'secret' }
  let(:uri)          { 'uri' }
  let(:body)         { 'body' }

  # derived parameters
  let(:time)         { Time.utc(2015, 5, 7) }
  let(:time_rfc2616) { time.httpdate}
  let(:hash)         { 'hash' }

  before { Timecop.freeze time }
  after  { Timecop.return }

  context 'uploading' do
    it 'computes md5sum of body' do
      expect(Digest::MD5).to receive(:hexdigest).with(body).and_return(hash)
      subject.build_headers key, secret, 'post', uri, body
    end

    it 'computes HMAC256 of verb, uri, content, and date' do
      allow(Digest::MD5).to receive(:hexdigest).and_return(hash)

      expect(Gibberish).to receive(:HMAC256).with(secret, "POST#{uri}#{hash}#{time_rfc2616}")
      headers = subject.build_headers key, secret, 'post', uri, body
    end
  end

  context 'downloading' do
    it 'computes HMAC256 of verb, uri, and date' do
      expect(Gibberish).to receive(:HMAC256).with(secret, "GET#{uri}#{time_rfc2616}")
      headers = subject.build_headers key, secret, 'get', uri
    end
  end

  context 'common' do
    it 'includes current date in RFC2616 format in header' do
      headers = subject.build_headers key, secret, 'get', uri
      expect(headers['Date']).to eq time_rfc2616
    end

    it 'includes a default content-type' do
      headers = subject.build_headers key, secret, 'get', uri
      expect(headers['Content-Type']).to eq 'application/json'
    end
  end

end
