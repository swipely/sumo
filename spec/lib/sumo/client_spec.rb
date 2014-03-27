require 'spec_helper'

describe Sumo::Client do
  describe '#initialize' do
    let(:creds) {
      {
        'email' => 'test@test.com',
        'password' => 'example'
      }
    }

    context 'with no arguments' do
      subject { Sumo::Client.new }
      before { Sumo.stub(:creds).and_return(creds) }

      it 'sets the default credentials' do
        subject.email.should == 'test@test.com'
        subject.password.should == 'example'
      end
    end

    context 'with an argument' do
      subject { Sumo::Client.new(creds) }

      it 'sets the credentials to that argument' do
        subject.email.should == 'test@test.com'
        subject.password.should == 'example'
      end
    end
  end

  describe '#request' do
    let(:connection) { double(:connection) }
    let(:response) { double(:response) }
    let(:creds) {
      {
        'email' => 'creds@email.com',
        'password' => 'test'
      }
    }
    let(:encoded) { Base64.encode64('creds@email.com:test').strip }
    subject { Sumo::Client.new(creds) }
    before { subject.stub(:connection).and_return(connection) }

    it 'sets the correct headers' do
      subject.stub(:handle_errors!)
      response.stub(:body)
      response.stub(:headers).and_return({})
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
