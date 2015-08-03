require 'spec_helper'

RSpec.describe Synapsis::User do
  context '.add_kyc/.verify_kyc' do
    let!(:add_kyc_params) {{
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

    }}

    context 'SSN validation successful, no need for doc/verify' do
      it 'adds a KYC' do
        added_kyc_response = Synapsis::User.add_kyc(add_kyc_params)
        expect(added_kyc_response.success).to be_truthy
        expect(added_kyc_response.message.en).to eq 'SSN information verified'
      end
    end

    context 'SSN validation successful, no need for doc/verify' do
      it 'returns a hash of questions' do
        partially_verified_kyc_params = add_kyc_params.clone
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
        failed_kyc_params = add_kyc_params.clone
        failed_kyc_params[:user][:doc][:document_value] = '1111'

        expect { Synapsis::User.add_kyc(failed_kyc_params) }.to raise_error(Synapsis::Error).with_message('Invalid SSN information supplied. Request user to submit a copy of passport/divers license and SSN via user/doc/attachments/add')
      end
    end
  end
end
