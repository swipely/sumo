require 'spec_helper'

describe SumoJob::Client do
  describe '#initialize' do
    let(:creds) { 'email@email.email:password' }

    context 'with no arguments' do
      subject { SumoJob::Client.new }
      before { SumoJob.stub_chain(:config, :load_creds!).and_return(creds) }
      it 'sets the default credentials' do
        subject.creds.should == creds
      end
    end

    context 'with an argument' do
      subject { SumoJob::Client.new(creds) }

      it 'sets the credentials to that argument' do
        subject.creds.should == creds
      end
    end
  end

  describe '#request' do
    let(:connection) { double(:connection) }
    let(:response) { double(:response) }
    let(:creds) { 'creds@email.com:test' }
    let(:encoded) { Base64.encode64(creds).strip }
    subject { SumoJob::Client.new(creds) }
    before { subject.stub(:connection).and_return(connection) }

    it 'sets the correct headers' do
      subject.stub(:handle_errors!)
      response.stub(:body)
      connection.should_receive(:request)
                .with(
                  :method => :get,
                  :path => '/',
                  :headers => {
                    'Content-Type' => 'application/json',
                    'Accept' => 'application/json',
                    'Authorization' => "Basic #{encoded}" })
                .and_return(response)
      subject.request(:method => :get, :path => '/')
    end

    context 'when a 2xx-level status code is returned by the API' do
      let(:body) { 'TEST RESULT' }
      let(:response) { double(:response, :status => 200, :body => body) }
      before { connection.stub(:request).and_return(response) }

      it 'returns the response body' do
        subject.request(:method => :get, :path => '/').should == body
      end
    end

    context 'when a 4xx-level status code is returned by the API' do
      let(:response) { double(:response, :status => 400, :body => body) }
      let(:body) { { 'message' => message }.to_json }
      let(:message) { 'Client Error' }
      before { connection.stub(:request).and_return(response) }

      context 'when a message can be parsed out of the response' do
        it 'raises a ClientError with that message' do
          expect { subject.request(:method => :post, :path => '/') }
            .to raise_error(SumoJob::Error::ClientError, message)
        end
      end

      context 'when a message cannot be parsed out of the response' do
        let(:message) { nil }

        it 'raises a ClientError with the default error message' do
          expect { subject.request(:method => :delete, :path => '/') }
            .to raise_error(SumoJob::Error::ClientError,
                            SumoJob::Client::DEFAULT_ERROR_MESSAGE)
        end
      end
    end

    context 'when a 5xx-level status code is returned by the API' do
      let(:response) { double(:response, :status => 500, :body => body) }
      let(:body) { { 'message' => message }.to_json }
      let(:message) { 'Server Error' }
      before { connection.stub(:request).and_return(response) }

      context 'when a message can be parsed out of the response' do
        it 'raises a ServerError with that message' do
          expect { subject.request(:method => :post, :path => '/') }
            .to raise_error(SumoJob::Error::ServerError, message)
        end
      end

      context 'when a message cannot be parsed out of the response' do
        let(:message) { nil }

        it 'raises a ServerError with the default error message' do
          expect { subject.request(:method => :delete, :path => '/') }
            .to raise_error(SumoJob::Error::ServerError,
                            SumoJob::Client::DEFAULT_ERROR_MESSAGE)
        end
      end
    end
  end

  [:get, :post, :delete].each do |http_method|
    describe "##{http_method}" do
      subject { SumoJob::Client.new('') }

      it "sends a request where the HTTP method is #{http_method}" do
        subject.should_receive(:request).with(:method => http_method)
        subject.public_send(http_method, {})
      end
    end
  end
end
