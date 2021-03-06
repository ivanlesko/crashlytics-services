require 'spec_helper'

describe Service::OpsGenie do

  it 'has a title' do
    expect(Service::OpsGenie.title).to eq('OpsGenie')
  end

  describe 'schema and display configuration' do
    subject { Service::OpsGenie }

    it { is_expected.to include_string_field :api_key }
    it { is_expected.to include_page 'API Key', [:api_key] }
  end

  describe 'receive_verification' do
    before do
      @config = { :api_key => 'OpsGenie API key' }
      @service = Service::OpsGenie.new('verification', {})
      @payload = 'does not matter'
    end

    it 'should succeed upon successful api response' do
      test = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.post('/') { [200, {}, ''] }
        end
      end

      allow(@service).to receive(:http_post)
        .with('https://api.opsgenie.com/v1/json/crashlytics')
        .and_return(test.post('/'))

      resp = @service.receive_verification(@config, @payload)
      expect(resp).to eq([true,  'Successfully verified OpsGenie settings'])
    end

    it 'fails upon unsuccessful api response' do
      test = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.post('/') { [500, {}, ''] }
        end
      end

      allow(@service).to receive(:http_post)
        .with('https://api.opsgenie.com/v1/json/crashlytics')
        .and_return(test.post('/'))

      resp = @service.receive_verification(@config, @payload)
      expect(resp).to eq([false, "Couldn't verify OpsGenie settings; please check your API key."])
    end
  end

  describe 'receive_issue_impact_change' do
    before do
      @config = {}
      @service = Service::OpsGenie.new('issue_impact_change', {})
      @payload = 'does not matter'
    end

    it 'succeeds upon successful api response' do
      test = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.post('/v1/json/crashlytics') { [200, {}, "{}"] }
        end
      end

      allow(@service).to receive(:http_post)
        .with('https://api.opsgenie.com/v1/json/crashlytics')
        .and_return(test.post('/v1/json/crashlytics'))

      resp = @service.receive_issue_impact_change(@config, @payload)
      expect(resp).to eq(:no_resource)
    end

    it 'fails upon unsuccessful api response' do
      test = Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.post('/v1/json/crashlytics') { [500, {}, "title not given"] }
        end
      end

      allow(@service).to receive(:http_post)
        .with('https://api.opsgenie.com/v1/json/crashlytics')
        .and_return(test.post('/v1/json/crashlytics'))

      expect { @service.receive_issue_impact_change(@config, @payload) }.to raise_error 'OpsGenie issue creation failed - HTTP status code: 500, body: title not given'
    end
  end
end
