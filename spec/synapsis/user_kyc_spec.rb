require 'spec_helper'

RSpec.describe Synapsis::User do
  context '.add_kyc' do
    context 'SSN validation successful, no need for doc/verify' do
      it 'adds a KYC' do
        add_kyc_params = {
          login: {
            oauth_key: SampleUser.oauth_consumer_key
          },
          user: {
            doc: {
              birth_day: 4,
              birth_month: 2,
              birth_year: 1940,
              name_first: SampleUser.name_first,
              name_last: SampleUser.name_last,
              address_street1: '1 Infinate Loop',
              address_postal_code: '95014',
              address_country_code: 'US',
              document_value: '2222',
              document_type: 'SSN'
            },
            fingerprint: SampleUser.fingerprint
          }
        }

        added_kyc_response = Synapsis::User.add_kyc(add_kyc_params)
        expect(added_kyc_response.success).to be_truthy
        expect(added_kyc_response.message.en).to eq 'SSN information verified'
      end
    end
  end
end
