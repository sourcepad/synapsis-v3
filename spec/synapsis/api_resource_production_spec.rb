require 'spec_helper-prod'

RSpec.describe Synapsis::APIResource, hidden_from_ci: true do
  context 'X-SP-PROD and URL host' do
    it "sets an X-SP-PROD header to YES if Synapsis's environment is configured to 'production' and the URL host is the production environment" do
      response = Synapsis::APIResource.request(
        :post,
        'sample_url',
        {})

      expect(response.env.request_headers['X-SP-PROD']).to eq 'YES'
      expect(response.env.url.to_s).to eq "https://synapsepay.com/sample_url"
    end
  end
end
