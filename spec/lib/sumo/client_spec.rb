require 'spec_helper'

describe Sumo::Client do
  describe '#initialize' do
    let(:creds) {
      {
        'access_id' => 'test',
        'access_key' => 'example'
      }
    }

    context 'with no arguments' do
      subject { Sumo::Client.new }
      before { Sumo.stub(:creds).and_return(creds) }

      it 'sets the default credentials' do
        subject.access_id.should == 'test'
        subject.access_key.should == 'example'
      end
    end

    context 'with an argument' do
      subject { Sumo::Client.new(creds) }

      it 'sets the credentials to that argument' do
        subject.access_id.should == 'test'
        subject.access_key.should == 'example'
      end
    end
  end

  describe '#request' do
    let(:connection) { double(:connection) }
    let(:response) { double(:response) }
    let(:creds) {
      {
        'access_id' => 'creds',
        'access_key' => 'test'
      }
    }
    let(:encoded) { Base64.encode64('creds:test').strip }
    subject { Sumo::Client.new(creds) }
    before { subject.stub(:connection).and_return(connection) }

    it 'sets the correct headers' do
      subject.stub(:handle_errors!)
      response.stub(:body)
      response.stub(:headers).and_return({})
      response.stub(:status).and_return(200)
      connection.should_receive(:request)
                .with(
                  :method => :get,
                  :path => '/api/v1/',
                  :headers => {
                    'Content-Type' => 'application/json',
                    'Accept' => 'application/json',
                    'Authorization' => "Basic #{encoded}" })
                .and_return(response)
      subject.request(:method => :get, :path => '/')
    end

    context 'when a 2xx-level status code is returned by the API' do
      let(:body) { 'TEST RESULT' }
      let(:cookie) { 'oreo' }
      let(:headers) { {'Set-Cookie' => cookie } }
      let(:response) {
        double(:response, :status => 200, :body => body, :headers => headers)
      }
      before { connection.stub(:request).and_return(response) }

      it 'returns the response body' do
        subject.request(:method => :get, :path => '/').should == body
      end

      it 'sets the cookie' do
        subject.request(:method => :get, :path => '/')
        connection.should_receive(:request)
                  .with(
                    :method => :get,
                    :path => '/api/v1/',
                    :headers => {
                      'Content-Type' => 'application/json',
                      'Accept' => 'application/json',
                      'Cookie' => cookie,
                      'Authorization' => "Basic #{encoded}" })
                  .and_return(response)
        subject.request(:method => :get, :path => '/')
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
            .to raise_error(Sumo::Error::ClientError, message)
        end
      end

      context 'when a message cannot be parsed out of the response' do
        let(:message) { nil }

        it 'raises a ClientError with the default error message' do
          expect { subject.request(:method => :delete, :path => '/') }
            .to raise_error(Sumo::Error::ClientError,
                            Sumo::Client::DEFAULT_ERROR_MESSAGE)
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
            .to raise_error(Sumo::Error::ServerError, message)
        end
      end

      context 'when a message cannot be parsed out of the response' do
        let(:message) { nil }

        it 'raises a ServerError with the default error message' do
          expect { subject.request(:method => :delete, :path => '/') }
            .to raise_error(Sumo::Error::ServerError,
                            Sumo::Client::DEFAULT_ERROR_MESSAGE)
        end
      end
    end

    context 'when a 3xx-level status code is returned by the API' do
      let(:cookie) { 'oreo' }
      let(:headers) { {'Set-Cookie' => cookie } }
      let(:default_connection) { double(:default_connection) }
      let(:redirect_connection) { double(:redirect_connection) }

      before do
        # Do not stub full connection method but only Excon.
        subject.stub(:connection).and_call_original
        default_connection.stub(:request).and_return(response)
        allow(Excon).to receive(:new)
          .with('https://api.sumologic.com').and_return default_connection
        allow(Excon).to receive(:new)
          .with('https://api.us2.sumologic.com').and_return redirect_connection
      end

      context 'and the redirection url is within sumologic domain' do
        let(:response) do
          double(:response, :status => 301, :body => '', :headers => {
            'Location' => 'https://api.us2.sumologic.com/api/v1/jobs'
          })
        end
        let(:final_response) do
          double(:response, :status => 200, :body => '', :headers => {})
        end

        it 'should follow it' do
          expect(default_connection).to receive(:request)
                  .with(
                    :method => :get,
                    :path => '/api/v1/',
                    :headers => {
                      'Content-Type' => 'application/json',
                      'Accept' => 'application/json',
                      'Authorization' => "Basic #{encoded}" })
                  .and_return(response)

          expect(redirect_connection).to receive(:request)
            .with(
              :method => :get,
              :path => '/api/v1/',
              :headers => {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
                'Authorization' => "Basic #{encoded}" })
            .and_return(final_response)
          subject.request(:method => :get, :path => '/')
        end
      end

      context 'and the redirection url is outside of sumologic' do
        let(:response) do
          double(:response, :status => 301, :body => '', :headers => {
            'Location' => 'https://donotfollow.me/api/v1/jobs'
          })
        end

        it 'should not follow it' do
          expect(default_connection).to receive(:request)
                  .with(
                    :method => :get,
                    :path => '/api/v1/',
                    :headers => {
                      'Content-Type' => 'application/json',
                      'Accept' => 'application/json',
                      'Authorization' => "Basic #{encoded}" })
                  .once
                  .and_return(response)
          expect(Excon).not_to receive(:new)
            .with('https://donotfollow.me')
          expect do
            subject.request(:method => :get, :path => '/')
          end.to raise_error 'Base url out of allowed domain.'
        end
      end

      context 'and there is a redirection loop' do
        let(:response) do
          double(:response, :status => 301, :body => '', :headers => {
            'Location' => 'https://api.us2.sumologic.com/api/v1/jobs'
          })
        end

        it 'should throw a too many redirections error' do
          expect(default_connection).to receive(:request)
                  .with(
                    :method => :get,
                    :path => '/api/v1/',
                    :headers => {
                      'Content-Type' => 'application/json',
                      'Accept' => 'application/json',
                      'Authorization' => "Basic #{encoded}" })
                  .and_return(response)

          expect(redirect_connection).to receive(:request)
            .with(
              :method => :get,
              :path => '/api/v1/',
              :headers => {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
                'Authorization' => "Basic #{encoded}" })
            .exactly(10).times
            .and_return(response)

          expect do
            subject.request(:method => :get, :path => '/')
          end.to raise_error 'Too many redirections.'
        end
      end
    end
  end

  [:get, :post, :delete].each do |http_method|
    describe "##{http_method}" do
      subject { Sumo::Client.new('') }

      it "sends a request where the HTTP method is #{http_method}" do
        subject.should_receive(:request).with(:method => http_method)
        subject.public_send(http_method, {})
      end
    end
  end
end
