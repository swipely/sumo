require 'spec_helper'

describe SumoJob::Config do
  let(:test_config_file) {
    File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'sumo-creds')
  }

  describe '#initialize' do
    let(:config_file) { '/etc/sumo-creds' }
    subject { SumoJob::Config.new(config_file) }

    it 'sets the @config_file instance variable' do
      subject.config_file.should == config_file
    end
  end

  describe '#file_specified?' do
    context 'when SumoJob::DEFAULT_CONFIG_FILE is not equal to @config_file' do
      let(:config_file) { '/etc/sumo-creds' }
      subject { SumoJob::Config.new(config_file) }

      it 'returns true' do
        subject.file_specified?.should be_true
      end
    end

    context 'when SumoJob::DEFAULT_CONFIG_FILE is equal to @config_file' do
      subject { SumoJob::Config.new }

      it 'returns false' do
        subject.file_specified?.should be_false
      end
    end
  end

  describe '#env_creds' do
    let(:email) { 'test@test.net' }
    let(:password) { 'trustno1' }
    let(:creds) { [email, password].join(':') }

    before { ENV['SUMO_CREDS'] = creds }
    after { ENV['SUMO_CREDS'] = nil }

    it 'retrieves the $SUMO_CREDS environment variable' do
      subject.env_creds.should == creds
    end
  end

  describe '#file_creds' do
    subject { SumoJob::Config.new(config_file) }

    context 'when @config_file is not a file' do
      let(:config_file) { '/not/a/file' }

      it 'returns nil' do
        subject.file_creds.should be_nil
      end
    end

    context 'when @config_file is a file' do
      let(:config_file) { test_config_file }

      it 'returns the contents of that file' do
        subject.file_creds.should == File.read(config_file).strip
      end
    end
  end

  describe '#load_creds' do
    let(:email) { 'test@test.net' }
    let(:password) { 'trustsum1' }
    let(:creds) { [email, password].join(':') }

    before { ENV['SUMO_CREDS'] = creds }
    after { ENV['SUMO_CREDS'] = nil }

    context 'when a config file is not specified' do
      it 'prefers the environment variable' do
        subject.load_creds.should == ENV['SUMO_CREDS']
      end
    end

    context 'when a config file is specified' do
      subject { SumoJob::Config.new(test_config_file) }

      it 'prefers the config file' do
        subject.load_creds.should == File.read(test_config_file).strip
      end
    end
  end

  describe '#load_creds!' do
    context 'when the configuration cannot be found' do
      before { subject.stub(:load_creds).and_return(nil) }

      it 'raises an error' do
        expect { subject.load_creds! }
          .to raise_error(SumoJob::Error::NoCredsFound)
      end
    end

    context 'when the configuration can be found' do
      let(:creds) { 'sumo@sumo.net:my-pass' }
      before { subject.stub(:load_creds).and_return(creds) }

      it 'returns the configuration' do
        subject.load_creds!.should == creds
      end
    end
  end
end
