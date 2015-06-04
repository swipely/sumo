require 'spec_helper'

describe Sumo::Search do
  before { Sumo.creds rescue Sumo.creds = 'fake@creds.com:password' }

  describe '.create' do
    let(:params) {
      {
        query: '| count _sourceCategory',
        from: '2014-01-01T00:00:00',
        to: '2014-03-01T00:00:00',
        time_zone: 'EST'
      }
    }
    subject { Sumo::Search.create(params) }

    it 'sets the @id and @client', :vcr do
      subject.id.should_not be_nil
      subject.client.should_not be_nil
    end
  end

  describe '#status' do
    let(:params) {
      {
        query: '| count _sourceCategory',
        from: '2013-01-01T00:00:00',
        to: '2014-03-01T00:00:00',
        time_zone: 'EST'
      }
    }
    let(:expected_keys) {
      %w(
        state
        pendingWarnings
        pendingErrors
        histogramBuckets
        messageCount
        recordCount
      ).sort
    }
    subject { Sumo::Search.create(params) }

    it 'returns the status of the search', :vcr do
      subject.status.keys.sort.should == expected_keys
    end
  end

  describe '#delete!' do
    let(:params) {
      {
        query: '| count _sourceCategory',
        from: '2014-01-01T00:00:00',
        to: '2014-02-01T00:00:00',
        time_zone: 'EST'
      }
    }
    subject { Sumo::Search.create(params) }

    before { subject.delete! }

    it 'deletes the search', :vcr do
      expect { subject.status }.to raise_error(Sumo::Error::ClientError)
    end
  end

  describe '#messages' do
    let(:params) {
      {
        query: '| count _sourceCategory',
        from: '2014-01-01T00:00:00',
        to: '2014-01-07T00:00:00',
        time_zone: 'EST'
      }
    }
    let(:messages) { subject.messages.to_a }
    subject { Sumo::Search.create(params) }

    before { Sumo::Collection.any_instance.stub(:sleep) }

    it 'returns an Enumerator of each message in the search', :vcr do
      messages.should be_all { |message| message.is_a?(Hash) }
      messages.length.should == subject.status['messageCount']
    end
  end

  describe '#records' do
    let(:params) {
      {
        query: '| count _sourceCategory',
        from: '2014-01-01T00:00:00',
        to: '2014-01-04T00:00:00',
        time_zone: 'EST'
      }
    }
    let(:records) { subject.records.to_a }
    subject { Sumo::Search.create(params) }

    before { Sumo::Collection.any_instance.stub(:sleep) }

    it 'returns an Enumerator of each record in the search', :vcr do
      records.should be_all { |record| record.is_a?(Hash) }
      records.length.should == subject.status['recordCount']
    end
  end
end
