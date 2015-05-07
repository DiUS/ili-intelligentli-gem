describe ObservationWindow do

  context 'unbounded memory' do

    it 'raises error when there are no limit or span options' do
      expect{subject.new}.to raise_error(RuntimeError)
    end

  end

  context 'bounded memory by limit' do

    let(:limit) { 5 }
    let(:new_data) { [{ time: Time.now }] }

    subject { ObservationWindow.new limit: limit }

    it 'appends data until the limit' do
      (2*limit).times do |index|
        subject.concat(new_data)
        expect(subject.data.length).to be <= [index+1, limit].min
      end
    end

  end

  context 'bounded memory by time' do

    let(:span)           { '5m' }
    let(:initial_length) { 10 }

    subject { ObservationWindow.new span: span }

    before do
      subject.concat [{ time: Time.now }]*initial_length
    end

    it 'appends data within time span' do
      subject.concat( [{ time: Time.now }])
      expect(subject.data.length).to eq(initial_length+1)
    end

    it 'rejects data without time span' do
      subject.concat( [{ time: Time.now - 3600 }])
      expect(subject.data.length).to eq(initial_length)
    end

  end

  context 'sorted data' do

    let(:limit) { 5 }

    subject { ObservationWindow.new limit: limit }

    it 'sorts data ascending by time' do
      time = Time.now
      data = []
      limit.times do |index|
        data << { time: time }
        subject.concat([data.last])
        time -= 1
      end
      expect(subject.data).to eq data.reverse
    end

  end

end
