require 'spec_helper'

describe Sumo::CLI do
  subject { Sumo::CLI.new(File.expand_path(File.basename($0))) }

  around do |example|
    begin
      $stdout = StringIO.new
      example.run
    ensure
      $stdout = STDOUT
    end
  end

  context 'when the `-h` flag is passed' do
    let(:args) { ['-h'] }

    it 'prints the help message' do
      expect { subject.run(args) }.to raise_error(Clamp::HelpWanted)
    end
  end

  context 'when the `-v` flag is passed' do
    let(:args) { ['-v'] }

    before { subject.run(args) }

    it 'returns the version' do
      expect($stdout.string.strip).to eq(Sumo::VERSION)
    end
  end

  context 'when an incomplete query is passed' do
    let(:args) { ['-q', 'Some Query'] }

    before { Sumo::Search.stub(:create).and_raise(Sumo::Error::ClientError) }

    it 'exits with status `1`' do
      pid = fork { subject.run(args) }
      Process.wait(pid)
      expect($?).to_not be_success
    end
  end

  context 'when a complete query is passed in' do
    let(:args) do
      %w(-q TEST -f 2014-01-01T00:00:00 -t 2014-01-02T00:00:00 -z EST)
    end

    context 'when there are no credentials' do
      before { Sumo.stub(:creds).and_raise(Sumo::Error::NoCredsFound) }

      it 'exits with status `1`' do
        pid = fork { subject.run(args) }
        Process.wait(pid)
        expect($?).to_not be_success
      end
    end

    context 'when there are credentials' do
      let(:creds) do
        {
          'email' => 'test@email.net',
          'password' => 'sumo'
        }
      end
      let(:messages) { [{ '_raw' => 'first' }, { '_raw' => 'second' }] }
      let(:raw_messages) { messages.map { |message| message['_raw'] } }
      let(:fake_search) { double(Sumo::Search, messages: messages) }

      before do
        Sumo.stub(:creds).and_return(creds)
        Sumo::Search.stub(:create).and_return(fake_search)
      end

      it 'executes the query' do
        subject.run(args)
        expect($stdout.string.strip).to eq(raw_messages.join("\n"))
      end
    end
  end
end
