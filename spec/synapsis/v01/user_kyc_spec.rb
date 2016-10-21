require 'spec_helper'

RSpec.describe Synapsis::V01::User do
  let(:add_kyc_params) {{
    login: {
      oauth_key: ''
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
      fingerprint: UserFactory.default_fingerprint
    }
  }}

  context '.add_kyc/.verify_kyc' do
    # We need to create users because Synapse limits doc attachments (verify_kyc) to 5 per user. Then we need to create users before each test because a partially successful doc attachment affects subsequent requests' output.

    context 'SSN validation successful, no need for doc/verify' do
      it "confirms that the user's virtual KYC status is SUBMITTED|VALID" do
        user = UserFactory.create_user
        add_kyc_params[:login][:oauth_key] = user.oauth.oauth_key
        added_kyc_response = Synapsis::V01::User.add_kyc(add_kyc_params)

        expect(added_kyc_response.success).to be_truthy
        expect(added_kyc_response.user.doc_status.virtual_doc).to eq Synapsis::User::DocumentStatus::SUBMITTED_VALID
      end
    end

    context 'Validation is partially successful. KBA verification required.' do
      it 'returns a hash of questions--and a subsequent request to a different endpoint completes the KYC process' do
        user = UserFactory.create_user
        partially_verified_kyc_params = add_kyc_params.clone
        partially_verified_kyc_params[:user][:doc][:document_value] = '3333'
        partially_verified_kyc_params[:login][:oauth_key] = user.oauth.oauth_key

        partially_added_kyc_response = Synapsis::V01::User.add_kyc(partially_verified_kyc_params)

        expect(partially_added_kyc_response.success).to be_truthy
        expect(partially_added_kyc_response.message.en).to eq 'Document information submitted. Please answer the attached KBA questions.'
        expect(partially_added_kyc_response.question_set.id).not_to be_empty
        expect(partially_added_kyc_response.question_set.questions).to be_a_kind_of Array

        verify_kyc_params = {
          login: {
            oauth_key: user.oauth.oauth_key
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
            fingerprint: UserFactory.default_fingerprint
          }
        }

        completed_kyc_response = Synapsis::V01::User.verify_kyc(verify_kyc_params)

        expect(completed_kyc_response.success).to be_truthy
        expect(completed_kyc_response.message.en).to eq 'KBA submitted'
        expect(completed_kyc_response.user.permission).to include 'RECEIVE'
        expect(completed_kyc_response.user.doc_status.virtual_doc).to eq Synapsis::User::DocumentStatus::SUBMITTED_VALID
      end
    end

    context 'SSN validation fails -- when means no SSN verification was found' do
      it 'raises a Synapsis::Error for submitting invalid SSN information' do
        user = UserFactory.create_user
        failed_kyc_params = add_kyc_params.clone
        failed_kyc_params[:user][:doc][:document_value] = '1111'
        failed_kyc_params[:login][:oauth_key] = user.oauth.oauth_key

        expect { Synapsis::V01::User.add_kyc(failed_kyc_params) }.to raise_error(Synapsis::Error)
      end
    end

    context '.add_document' do
      context 'happy path' do
        it 'attaches' do
          user = UserFactory.create_user

          add_kyc_params[:login][:oauth_key] = user.oauth.oauth_key
          added_kyc_response = Synapsis::V01::User.add_kyc(add_kyc_params)

          photo_path = 'spec/support/test_photo.jpg'

          doc_params = {
            login: {
              oauth_key: user.oauth.oauth_key
            },
            user: {
              doc: {
                attachment: photo_path
              },
              fingerprint: UserFactory.default_fingerprint
            }
          }

          add_document_response = Synapsis::V01::User.add_document(doc_params)

          successful_show_user_response = Synapsis::User.show({}, UserFactory.default_authentication_headers(user))

          expect(add_document_response.message.en).to eq 'Attachment added'
          expect(add_document_response.user.doc_status.physical_doc).to eq Synapsis::User::DocumentStatus::SUBMITTED_REVIEWING
        end
      end
    end
  end
end
