require 'spec_helper'
require 'base64'

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

    context 'errors' do
      xit 'pending' do
      end
    end
  end

  context '.sign_in' do
    context 'happy path' do
      it 'signs in the user' do
        sign_in_user_params = {
          login: {
            email: 'sample_user@synapsis.com',
            password: '5ourcep4d'
          },
          user: {
            _id: {
              '$oid' => '55bf009b86c2733920d5b0af'
            },
            fingerprint: 'suasusau21324redakufejfjsf',
            ip: '192.168.0.1'
          }
        }

        sign_in_user_response = Synapsis::User.sign_in(sign_in_user_params)
        expect(sign_in_user_response.success).to be_truthy
        expect(sign_in_user_response.oauth.oauth_key).not_to be_empty
      end
    end

    context 'errors' do
      xit 'pending' do
      end
    end
  end

  context 'non-create methods (create a customer beforehand to get around refreshing token issue)' do
    before(:all) do
      @user = UserFactory.create_user
      @oid = @user.user._id.send(:$oid)
      @oauth_token = @user.oauth.oauth_key
    end

    context '.update' do
      it 'updates the user' do
        sign_in_user_params = {
          login: {
            email: 'synapsis_kyc_spec@sourcepad.com',
            password: '5ourcep4d'
          },
          user: {
            _id: {
              '$oid' => @oid,
            },
            fingerprint: UserFactory.default_fingerprint,
            update: {
              'legal_name' => 'Hello World'
            }
          }
        }

        sign_in_user_response = Synapsis::User.sign_in(sign_in_user_params)

        expect(sign_in_user_response.success).to be_truthy
        expect(sign_in_user_response.user.legal_names.include?('Hello World')).to be_truthy
      end
    end
  end

  context '.search' do
    context 'happy path, filtered via email' do
      it 'is able to search for the user' do
        search_params = {
          'filter' => {
            'page' => 1,
            'exact_match' => true,
            'query' => 'synapsistest@sourcepad.com'
          }
        }

        successful_search_user_response = Synapsis::User.search(search_params)
        expect(successful_search_user_response.success).to eq true
        expect(successful_search_user_response.users).to be_a_kind_of(Array)
      end
    end
  end
end
