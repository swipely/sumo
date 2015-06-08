require 'spec_helper'

describe Sumo::Client do
  describe '#initialize' do
    let(:creds) do
      {
        'email' => 'test@test.com',
        'password' => 'example'
      }
    end

    context 'with no arguments' do
      subject { Sumo::Client.new }
      before do
        allow(Sumo)
          .to receive(:creds)
          .and_return(creds)
      end

      it 'sets the default credentials' do
        expect(subject.email).to eq('test@test.com')
        expect(subject.password).to eq('example')
      end
    end

    context 'with an argument' do
      subject { Sumo::Client.new(creds) }

      it 'sets the credentials to that argument' do
        expect(subject.email).to eq('test@test.com')
        expect(subject.password).to eq('example')
      end
    end
  end

  describe '#request' do
    let(:connection) { double(:connection) }
    let(:response) { double(:response) }
    let(:creds) do
      {
        'email' => 'creds@email.com',
        'password' => 'test'
      }
    end
    let(:encoded) { Base64.encode64('creds@email.com:test').strip }
    subject { Sumo::Client.new(creds) }
    before do
      allow(subject)
        .to receive(:connection)
        .and_return(connection)
    end

    it 'sets the correct headers' do
      allow(subject).to receive(:handle_errors!)
      allow(response).to receive(:body)
      allow(response).to receive(:headers).and_return({})
      expect(connection).to receive(:request)
        .with(
          method: :get,
          path: '/api/v1/',
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Authorization' => "Basic #{encoded}" })
        .and_return(response)
      subject.request(method: :get, path: '/')
    end

    context 'when a 2xx-level status code is returned by the API' do
      let(:body) { 'TEST RESULT' }
      let(:cookie) { 'oreo' }
      let(:headers) { { 'Set-Cookie' => cookie } }
      let(:response) do
        double(:response, status: 200, body: body, headers: headers)
      end
      before do
        allow(connection).to receive(:request).and_return(response)
      end

      it 'returns the response body' do
        expect(subject.request(method: :get, path: '/')).to eq(body)
      end

      it 'sets the cookie' do
        subject.request(method: :get, path: '/')
        allow(connection)
          .to receive(:request)
          .with(
            method: :get,
            path: '/api/v1/',
            headers: {
              'Content-Type' => 'application/json',
              'Accept' => 'application/json',
              'Cookie' => cookie,
              'Authorization' => "Basic #{encoded}" })
          .and_return(response)
        subject.request(method: :get, path: '/')
      end
    end

    context 'when a 4xx-level status code is returned by the API' do
      let(:response) { double(:response, status: 400, body: body) }
      let(:body) { { 'message' => message }.to_json }
      let(:message) { 'Client Error' }
      before { allow(connection).to receive(:request).and_return(response) }

      context 'when a message can be parsed out of the response' do
        it 'raises a ClientError with that message' do
          expect { subject.request(method: :post, path: '/') }
            .to raise_error(Sumo::Error::ClientError, message)
        end
      end

      context 'when a message cannot be parsed out of the response' do
        let(:message) { nil }

        it 'raises a ClientError with the default error message' do
          expect { subject.request(method: :delete, path: '/') }
            .to raise_error(
              Sumo::Error::ClientError,
              Sumo::Client::DEFAULT_ERROR_MESSAGE
            )
        end
      end
    end

    context 'when a 5xx-level status code is returned by the API' do
      let(:response) { double(:response, status: 500, body: body) }
      let(:body) { { 'message' => message }.to_json }
      let(:message) { 'Server Error' }
      before { allow(connection).to receive(:request).and_return(response) }

      context 'when a message can be parsed out of the response' do
        it 'raises a ServerError with that message' do
          expect { subject.request(method: :post, path: '/') }
            .to raise_error(Sumo::Error::ServerError, message)
        end
      end

      context 'when a message cannot be parsed out of the response' do
        let(:message) { nil }

        it 'raises a ServerError with the default error message' do
          expect { subject.request(method: :delete, path: '/') }
            .to raise_error(
              Sumo::Error::ServerError,
              Sumo::Client::DEFAULT_ERROR_MESSAGE
            )
        end
      end
    end
  end

  [:get, :post, :delete].each do |http_method|
    describe "##{http_method}" do
      subject { Sumo::Client.new('') }

      it "sends a request where the HTTP method is #{http_method}" do
        allow(subject)
          .to receive(:request)
          .with(method: http_method)
        subject.public_send(http_method, {})
      end
    end
  end
end
