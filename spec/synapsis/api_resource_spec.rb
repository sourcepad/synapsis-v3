require 'spec_helper'

RSpec.describe Synapsis::APIResource do
  context 'X-SP-GATEWAY' do
    it 'adds an X-SP-GATEWAY header composed of the client id and client secret' do
      response = Synapsis::APIResource.request(
        :post,
        'sample_url',
        {})

      expect(response.env.request_headers['X-SP-GATEWAY']). not_to be_nil
    end
  end

  context 'X-SP-PROD and URL host' do
    it "sets an X-SP-PROD header to NO if Synapsis's environment is not configured to 'production' and the URL host is the sandbox environment" do
      response = Synapsis::APIResource.request(
        :post,
        'sample_url',
        {})

      expect(response.env.request_headers['X-SP-PROD']).to eq 'NO'
      expect(response.env.url.to_s).to eq "https://sandbox.synapsepay.com/sample_url"
    end
  end

  context 'X-SP-USER' do
    it 'adds an X-SP-USER header if oauth_key and fingperint arguments were supplied' do
      response = Synapsis::APIResource.request(
        :post,
        'sample_url',
        {},
        oauth_key: 'hello',
        fingerprint: 'world'
      )

      expect(response.env.request_headers['X-SP-USER']). to eq 'hello|world'
    end

    it "doesn't apply those headers if one of those were not supplied" do
      response_with_no_oauth = Synapsis::APIResource.request(
        :post,
        'sample_url',
        {},
        fingerprint: 'world'
      )

      expect(response_with_no_oauth.env.request_headers['X-SP-USER']). to eq nil

      response_with_no_fingerprint = Synapsis::APIResource.request(
        :post,
        'sample_url',
        {},
        oauth_key: 'hello'
      )

      expect(response_with_no_oauth.env.request_headers['X-SP-USER']). to eq nil
    end
  end

  context 'X-SP-USER-IP' do
    it 'adds an X-SP-USER-IP header if an ip_address argument was supplied' do
      response = Synapsis::APIResource.request(
        :post,
        'sample_url',
        {},
        ip_address: '192.168.0.1'
      )

      expect(response.env.request_headers['X-SP-USER-IP']).to eq '192.168.0.1'
    end

    it "doesn't apply that header if the ip_address was not supplied" do
      response = Synapsis::APIResource.request(:post, 'sample_url', {})

      expect(response.env.request_headers['X-SP-USER-IP']).to eq nil
    end
  end
end
