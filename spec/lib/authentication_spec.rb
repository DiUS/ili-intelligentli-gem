describe Authentication do

  subject { Class.new { include Authentication }.new }

  before do
    Timecop.freeze Time.utc(2015, 5, 7)

    subject.instance_variable_set :@key,        'key'
    subject.instance_variable_set :@secret_key, 'secret'
  end
  after  { Timecop.return }

  it 'computes md5sum of body' do
    body = 'something'
    expect(Digest::MD5).to receive(:hexdigest).with(body).and_return('hash')
    subject.build_headers 'post', 'uri', body
  end

  it 'gets current date in RFC2616 format'
  it 'computes HMAC256 of verb, uri, content, and date'
  it 'builds a header'
  it 'includes a default content-type'
  it 'excludes content-type if set to nil'
  it 'includes specified content-type'
end
