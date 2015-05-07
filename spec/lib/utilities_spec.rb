describe Utilities do

  describe '#epoch_to_time' do

    let(:time)    { Time.utc(2015, 5, 7) }
    let(:data)    { [ {time: time} ] }
    let(:data_s)  { [ {time: time.to_i} ] }
    let(:data_ms) { [ {time: time.to_i * 1000} ] }
    let(:data_us) { [ {time: time.to_i * 1000000} ] }

    it 'accepts s precision' do
      expect(subject.epoch_to_time(data_ms, 'ms')).to eq(data)
    end

    it 'accepts ms precision' do
      expect(subject.epoch_to_time(data_ms, 'ms')).to eq(data)
    end

    it 'accepts us precision' do
      expect(subject.epoch_to_time(data_us, 'us')).to eq(data)
    end

    context 'complicated hash' do

      let(:data)    { [ {time: time, anything: 'and', everything: 'else'} ] }
      let(:data_ms) { [ {time: time.to_i * 1000, anything: 'and', everything: 'else'} ] }

      it 'leaves the rest of the hash alone' do
        expect(subject.epoch_to_time(data_ms, 'ms')).to eq(data)
      end

    end

  end

end
