require 'spec_helper'

describe Sumo::Config do
  let(:test_config_file) do
    File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'sumo-creds')
  end

  describe '#initialize' do
    let(:config_file) { '/etc/sumo-creds' }
    subject { Sumo::Config.new(config_file) }

    it 'sets the @config_file instance variable' do
      expect(subject.config_file).to eq(config_file)
    end
  end

  describe '#load_creds' do
    context 'when #load_creds! raises an error' do
      before do
        allow(subject)
          .to receive(:load_creds!)
          .and_raise(Sumo::Error::NoCredsFound)
      end

      it 'returns nil' do
        expect(subject.load_creds).to be_nil
      end
    end

    context 'when #load_creds! does not raise an error' do
      let(:creds) do
        {
          email: 'test@example.com',
          password: 'canthackthis'
        }
      end
      before { allow(subject).to receive(:load_creds!).and_return(creds) }

      it 'returns its return value' do
        expect(subject.load_creds).to eq(creds)
      end
    end
  end

  describe '#load_creds!' do
    subject { Sumo::Config.new(test_config_file) }

    context 'when the config file does not exist' do
      before { allow(File).to receive(:exist?).and_return(false) }

      it 'raises an error' do
        expect { subject.load_creds! }
          .to raise_error(Sumo::Error::NoCredsFound)
      end
    end

    context 'when the config file does exist' do
      context 'when the file is not valid YAML' do
        let(:test_config_file) do
          File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'bad-creds')
        end

        it 'raises an error' do
          expect { subject.load_creds! }
            .to raise_error(Sumo::Error::NoCredsFound)
        end
      end

      context 'when the file is valid YAML' do
        context 'but the specified key cannot be found' do
          before { ENV['SUMO_CREDENTIAL'] = 'does-not-exist' }
          after { ENV['SUMO_CREDENTIAL'] = nil }

          it 'raises an error' do
            expect { subject.load_creds! }
              .to raise_error(Sumo::Error::NoCredsFound)
          end
        end

        context 'when the specified key can be found' do
          let(:expected) do
            {
              'email' => 'test@example.com',
              'password' => 'trustno1'
            }
          end
          before { ENV['SUMO_CREDENTIAL'] = 'engineering' }
          after { ENV['SUMO_CREDENTIAL'] = nil }

          it 'returns those credentials' do
            expect(subject.load_creds!).to eq(expected)
          end
        end
      end
    end
  end
end
