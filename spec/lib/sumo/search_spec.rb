require 'spec_helper'

describe Sumo::Search do
  before do
    begin
      Sumo.creds
    rescue
      Sumo.creds = 'fake@creds.com:password'
    end
  end

  describe '.create' do
    let(:params) do
      {
        query: '| count _sourceCategory',
        from: '2014-01-01T00:00:00',
        to: '2014-03-01T00:00:00',
        time_zone: 'EST'
      }
    end
    subject { Sumo::Search.create(params) }

    it 'sets the @id and @client', :vcr do
      expect(subject.id).to_not be nil
      expect(subject.client).to_not be nil
    end
  end

  describe '#status' do
    let(:params) do
      {
        query: '| count _sourceCategory',
        from: '2013-01-01T00:00:00',
        to: '2014-03-01T00:00:00',
        time_zone: 'EST'
      }
    end
    let(:expected_keys) do
      %w(
        state
        pendingWarnings
        pendingErrors
        histogramBuckets
        messageCount
        recordCount
      ).sort
    end
    subject { Sumo::Search.create(params) }

    it 'returns the status of the search', :vcr do
      expect(subject.status.keys.sort).to eq(expected_keys)
    end
  end

  describe '#delete!' do
    let(:params) do
      {
        query: '| count _sourceCategory',
        from: '2014-01-01T00:00:00',
        to: '2014-02-01T00:00:00',
        time_zone: 'EST'
      }
    end
    subject { Sumo::Search.create(params) }

    before { subject.delete! }

    it 'deletes the search', :vcr do
      expect { subject.status }.to raise_error(Sumo::Error::ClientError)
    end
  end

  describe '#messages' do
    let(:params) do
      {
        query: '| count _sourceCategory',
        from: '2014-01-01T00:00:00',
        to: '2014-01-07T00:00:00',
        time_zone: 'EST'
      }
    end
    let(:messages) { subject.messages.to_a }
    subject { Sumo::Search.create(params) }

    before { allow_any_instance_of(Sumo::Collection).to receive(:sleep) }

    it 'returns an Enumerator of each message in the search', :vcr do
      expect(messages).to be_all { |message| message.is_a?(Hash) }
      expect(messages.length).to eq(subject.status['messageCount'])
    end
  end

  describe '#records' do
    let(:params) do
      {
        query: '| count _sourceCategory',
        from: '2014-01-01T00:00:00',
        to: '2014-01-04T00:00:00',
        time_zone: 'EST'
      }
    end
    let(:records) { subject.records.to_a }
    subject { Sumo::Search.create(params) }

    before { allow_any_instance_of(Sumo::Collection).to receive(:sleep) }

    it 'returns an Enumerator of each record in the search', :vcr do
      expect(records).to be_all { |record| record.is_a?(Hash) }
      expect(records.length).to eq(subject.status['recordCount'])
    end
  end
end
