require 'spec_helper'

RSpec.describe Synapsis::User do
  context '.create' do
    context 'happy path' do
      it 'creates a user and returns an OAuth token' do
        user_params = {
          logins: [
            email: 'synapsistest@sourcepad.com',
            password: '5ourcep4d',
            read_only: false
          ],
          phone_numbers: [
            '901.111.1111'
          ],
          legal_names: [
            'Synapsis Test'
          ],
          fingerprints: [
            'fingerprint' => 'suasusau21324redakufejfjsf'
          ],
          ips: [
            '192.168.0.1'
          ]
        }

        new_user_response = Synapsis::User.create(user_params)
        expect(new_user_response.success).to be_truthy
        expect(new_user_response.oauth.oauth_key).not_to be_empty
      end
    end
  end
end
