require 'spec_helper'

describe Sumo do
  describe '.config' do
    subject { Sumo.config }

    it { should be_a(Sumo::Config) }
  end

  describe '.config=' do
    let(:test_config) { double(:test_config) }

    it 'changes the config' do
      expect { Sumo.config = test_config }
        .to change { Sumo.config }
        .to(test_config)
    end
  end

  describe '.creds' do
    subject { Sumo.creds }

    it { should be_a(Hash) }
  end

  describe '.creds=' do
    let(:test_creds) { double(:creds) }

    it 'sets the creds' do
      expect { Sumo.creds = test_creds }
        .to change { Sumo.creds }
        .to(test_creds)
    end
  end

  describe '.client' do
    subject { Sumo.client }

    it { should be_a(Sumo::Client) }
  end

  describe '.client=' do
    let!(:original) { Sumo.client }
    let(:test_client) { double(:client) }

    after { Sumo.client = original }

    it 'sets the client' do
      expect { Sumo.client = test_client }
        .to change { Sumo.client }
        .to(test_client)
    end
  end

  describe '.search' do
    let(:params) {
      {
        :query => '| count _sourceCategory',
        :from => '2014-01-01T00:00:00',
        :to => '2014-01-04T00:00:00',
        :time_zone => 'EST'
      }
    }
    subject { Sumo.search(params) }

    it 'creates a new Sumo::Search', :vcr do
      expect(subject).to be_a(Sumo::Search)
    end
  end
end
