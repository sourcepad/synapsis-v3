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

  context '.update' do
    xit 'pending--updates the user' do
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
          "phone_number":"901.111.1111",
          validation_pin: '123456',
          ip: '192.168.0.1'
        },
        'update' => {
          'login' => {
            'email' => 'sample_user@synapsis.com',
            'password' => '5ourcep4d'
          },
          'phone_number' => '901.111.1112',
          # 'remove_phone_number' => '901.111.1111',
          'legal_name' => 'Hello World'
        }
      }

      sign_in_user_response = Synapsis::User.sign_in(sign_in_user_params)

      expect(sign_in_user_response.success).to be_truthy
      expect(sign_in_user_response.oauth.oauth_key).not_to be_empty
    end
  end

  context '.add_document' do
    context 'happy path' do
      it 'pending--unable to attach' do
        doc_params = {
          login: {
            oauth_key: SampleUser.oauth_consumer_key
          },
          user: {
            doc: {
              attachment: 'spec/test_file.txt'
            },
            fingerprint: SampleUser.fingerprint
          }
        }

        successful_add_document_response = Synapsis::User.add_document(doc_params)



        expect(successful_add_document_response.success).to eq true
        expect(successful_add_document_response.message.en).to eq 'Attachment added'
        expect(successful_add_document_response.user.permission).to eq 'SEND-AND-RECEIVE'
      end
    end
  end
end
