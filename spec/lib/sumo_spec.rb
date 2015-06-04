require 'spec_helper'

describe Sumo do
  describe '.config' do
    it 'is an instance of Sumo::Config' do
      expect(subject.config).to be_a(Sumo::Config)
    end
  end

  describe '.config=' do
    let(:test_config) { double(:test_config) }

    it 'changes the config' do
      expect { subject.config = test_config }
        .to change { subject.config }
        .to(test_config)
    end
  end

  describe '.creds' do
    it 'is present' do
      expect(subject.creds).to_not be_nil
    end
  end

  describe '.creds=' do
    let(:test_creds) { double(:creds) }

    it 'sets the creds' do
      expect { subject.creds = test_creds }
        .to change { subject.creds }
        .to(test_creds)
    end
  end

  describe '.client' do
    it 'is a Sumo::Client' do
      expect(subject.client).to be_a(Sumo::Client)
    end
  end

  describe '.client=' do
    let!(:original) { subject.client }
    let(:test_client) { double(:client) }

    after { subject.client = original }

    it 'sets the client' do
      expect { subject.client = test_client }
        .to change { subject.client }
        .to(test_client)
    end
  end

  describe '.search' do
    let(:params) do
      {
        query: '| count _sourceCategory',
        from: '2014-01-01T00:00:00',
        to: '2014-01-04T00:00:00',
        time_zone: 'EST'
      }
    end

    it 'creates a new Sumo::Search', :vcr do
      expect(subject.search(params)).to be_a(Sumo::Search)
    end
  end
end
