
require 'spec_helper'

RSpec.describe Synapsis::User do
  let(:add_document_params) {{
    documents: [
      email: 'hello@world.com',
      phone_number: '1231231234',
      'ip': '192.168.1.1 ',
      'name':'Charlie Brown',
      'alias':'Woof Woof',
      'entity_type':'M',
      'entity_scope':'Arts & Entertainment',
      'day':2,
      'month':5,
      'year':2009,
      'address_street':'Some Farm',
      'address_city':'SF',
      'address_subdivision':'CA',
      'address_postal_code':'94114',
      'address_country_code':'US',
      'virtual_docs':[
        {
          'document_value':'111-111-2222',
          'document_type':'SSN'
        }
    ],
    'physical_docs':[
      {
        'document_value':'spec/support/test_photo.jpg',
        'document_type':'GOVT_ID'
      },
      {
        'document_value':'spec/support/test_photo.jpg',
        'document_type':'EIN_DOC'
      },
    ],
    'social_docs':[
      {
        'document_value':'https://www.facebook.com/sankaet',
        'document_type':'FACEBOOK'
      }
      ]
    ]
  }
  }

  context 'add_document' do
    # We need to create users because Synapse limits doc attachments (verify_kyc) to 5 per user. Then we need to create users before each test because a partially successful doc attachment affects subsequent requests' output.
    context 'success--adds the physical docs and virtual docs, and subsequent responses confirm this' do
      it 'adds the actual physical docs' do
        user = UserFactory.create_user

        added_kyc_response = Synapsis::User.add_document(add_document_params, UserFactory.default_authentication_headers(user))

        successful_show_user_response = Synapsis::User.show({}, UserFactory.default_authentication_headers(user))

        expect(added_kyc_response.documents[0].physical_docs.find { |x| x.document_type == 'GOVT_ID' }).to be_truthy
        expect(added_kyc_response.documents[0].physical_docs.find { |x| x.document_type == 'EIN_DOC' }).to be_truthy
      end
    end

    context 'successful, but needs further validation (3333 case)' do
      it 'asks the questions, and if the answers make sense, the virtual_doc status becomes SUBMITTED|VALID' do
        user = UserFactory.create_user

        add_document_params[:documents][0][:virtual_docs][0][:document_value] = '3333'

        questions_response = Synapsis::User.add_document(add_document_params, UserFactory.default_authentication_headers(user))

        expect(questions_response.documents.first.virtual_docs.first.meta.question_set.questions).to be_truthy
        expect(questions_response.doc_status.virtual_doc).to eq 'MISSING|INVALID'

        answer_questions_params = {
          documents: [{
            id: questions_response.documents.first.id,
            virtual_docs: [{
            id: questions_response.documents.first.virtual_docs.first.id, meta: {
              question_set: {
                answers: [
                  { question_id: 1, answer_id: 1},
                  { question_id: 2, answer_id: 1},
                  { question_id: 3, answer_id: 1},
                  { question_id: 4, answer_id: 1},
                  { question_id: 5, answer_id: 1}
                ]
              }
            }
          }]
          }]
        }

        answered_questions_response = Synapsis::User.add_document(answer_questions_params, UserFactory.default_authentication_headers(user))

        expect(answered_questions_response.doc_status.virtual_doc).to eq 'SUBMITTED|VALID'
      end
    end

    context 'success--stagger submission of physical and virtual docs' do
      it 'shows physical as invalid first, then valid later' do
        user = UserFactory.create_user

        add_document_params[:documents].first[:physical_docs] = []

        added_kyc_response = Synapsis::User.add_document(add_document_params, UserFactory.default_authentication_headers(user))

        expect(added_kyc_response.doc_status.virtual_doc).to eq 'SUBMITTED|VALID'
        expect(added_kyc_response.doc_status.physical_doc).to eq 'MISSING|INVALID'

        add_document_params[:documents].first[:physical_docs] = [
          {
            'document_value':'spec/support/test_photo.jpg',
            'document_type':'GOVT_ID'
          },
          {
            'document_value':'spec/support/test_photo.jpg',
            'document_type':'EIN_DOC'
          },
        ]

        added_kyc_response2 = Synapsis::User.add_document(add_document_params, UserFactory.default_authentication_headers(user))

        expect(added_kyc_response2.doc_status.physical_doc).to eq 'SUBMITTED|VALID'
      end
    end
  end
end
