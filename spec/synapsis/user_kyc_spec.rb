require 'spec_helper'

RSpec.describe Synapsis::User do
  context '.add_kyc/.verify_kyc' do
    # We need to create users because Synapse limits doc attachments (verify_kyc) to 5 per user. Then we need to create users before each test because a partially successful doc attachment affects subsequent requests' output.
    before(:each) do
      @created_user = UserFactory.create_user
      @add_kyc_params = {
        login: {
          oauth_key: @created_user.oauth.oauth_key
        },
        user: {
          doc: {
            birth_day: 4,
            birth_month: 2,
            birth_year: 1940,
            name_first: 'Sample',
            name_last: 'KYCSpec',
            address_street1: '1 Infinate Loop',
            address_postal_code: '95014',
            address_country_code: 'US',
            document_value: '2222',
            document_type: 'SSN'
          },
          fingerprint: 'suasusau21324redakufejfjsf'
        }
      }
    end

    context 'SSN validation successful, no need for doc/verify' do
      it 'adds a KYC' do
        added_kyc_response = Synapsis::User.add_kyc(@add_kyc_params)

        expect(added_kyc_response.success).to be_truthy
        expect(added_kyc_response.message.en).to eq 'Document information verified.'

        viewed_user_params = {
          'filter' => {
            'page' => 1,
            'exact_match' => true,
            'query' => '5639f91086c27307e5ff6749'
          }
        }

        successful_search_user_response = Synapsis::User.search(viewed_user_params)

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

        binding.pry

        sign_in_user_response = Synapsis::User.sign_in(sign_in_user_params)

        binding.pry

        refresh_params = {
          login: {
            refresh_token: @created_user.oauth.refresh_token
          },
          user: {
            _id: {
              '$oid' => added_kyc_response.user._id.send(:$oid)
            },
            fingerprint: 'suasusau21324redakufejfjsf',
            ip: '192.168.0.1'
          }
        }

        refresh_response = Synapsis::User.refresh(refresh_params)
        binding.pry
      end
    end

    context 'SSN validation successful, no need for doc/verify' do
      it 'returns a hash of questions' do
        partially_verified_kyc_params = @add_kyc_params.clone
        partially_verified_kyc_params[:user][:doc][:document_value] = '0000'

        partially_added_kyc_response = Synapsis::User.add_kyc(partially_verified_kyc_params)
        expect(partially_added_kyc_response.success).to be_truthy
        expect(partially_added_kyc_response.message.en).to eq 'SSN information submitted. Please ask user to answer the attached questions and post them to user/doc/verify'
        expect(partially_added_kyc_response.question_set.id).not_to be_empty
        expect(partially_added_kyc_response.question_set.questions).to be_a_kind_of Array

        verify_kyc_params = {
          login: {
            oauth_key: SampleUser.oauth_consumer_key
          },
          user: {
            doc: {
              question_set_id: partially_added_kyc_response.question_set.id,
              answers: [
                { 'question_id': 1, 'answer_id': 1 },
                { 'question_id': 2, 'answer_id': 1 },
                { 'question_id': 3, 'answer_id': 1 },
                { 'question_id': 4, 'answer_id': 1 },
                { 'question_id': 5, 'answer_id': 1 }
              ]
            },
            fingerprint: SampleUser.fingerprint
          }
        }

        completed_kyc_response = Synapsis::User.verify_kyc(verify_kyc_params)

        expect(completed_kyc_response.success).to be_truthy
        expect(completed_kyc_response.message.en).to eq 'SSN answers submitted'
      end
    end

    context 'SSN validation fails -- when means no SSN verification was found' do
      it 'raises a Synapsis::Error for submitting invalid SSN information' do
        failed_kyc_params = @add_kyc_params.clone
        failed_kyc_params[:user][:doc][:document_value] = '1111'

        expect { Synapsis::User.add_kyc(failed_kyc_params) }.to raise_error(Synapsis::Error).with_message('Invalid SSN information supplied. Please submit a copy of passport/divers license via user/doc/attachments/add')
      end
    end
  end

  context '.add_document' do
    context 'happy path' do
      it 'attaches' do
        photo_path = 'spec/support/test_photo.jpg'
        new_user_response = UserFactory.create_user
        new_user_oauth_key = new_user_response.oauth.oauth_key

        doc_params = {
          login: {
            oauth_key: new_user_oauth_key
          },
          user: {
            doc: {
              attachment: photo_path
            },
            fingerprint: 'suasusau21324redakufejfjsf'
          }
        }

        doc = Synapsis::User.add_document(doc_params)

        linked_nodes = Synapsis::Node.show({
          login: { oauth_key: new_user_oauth_key },
          user: { fingerprint: 'suasusau21324redakufejfjsf' }
        })

        synapse_us_node = linked_nodes.nodes.first._id.send(:$oid)

        show_user_kyc_response = Synapsis::User.show_kyc(
          node: { _id: { "$oid" => synapse_us_node } },
          login: { oauth_key: new_user_oauth_key }
        )
      end
    end
  end
end
