require 'spec_helper'

RSpec.describe Synapsis::Transaction do
  context '.add' do
    context 'yo' do
      let(:add_transaction_params) {{
        login: { oauth_key: SampleSender.oauth_consumer_key },
        user: { fingerprint: SampleSender.fingerprint },
        trans: {
          from: {
            type: 'ACH-US',
            id: SampleSender.bank_id
          },
          to: {
            type: 'ACH-US',
            id: SampleReceiver.bank_id
          },
          amount: {
            amount: 10.10,
            currency: 'USD'
          }
        }
      }}

      context 'happy path' do
        it 'works' do
          add_transaction_response = Synapsis::Transaction.add(add_transaction_params)

          binding.pry
          expect(add_transaction_response.success).to be_truthy
          # expect(add_transaction_response.nodes.first._id.send(:$oid)).not_to be_nil
        end
      end

      context '' do
        xit 'paying to a receiver' do
        # Reciver is not authorizied to recive payments. Make the user go through the KYC process to enable reciving function
        end
      end

      context 'errors' do
        it 'wrong password raises a Synapsis Error' do
          wrong_password_bank_login_params = add_node_via_bank_login_params.clone
          wrong_password_bank_login_params[:node][:info][:bank_pw] = 'WRONG PASSWORD'
          expect { Synapsis::Node.add(wrong_password_bank_login_params) }.to raise_error(Synapsis::Error).with_message('Please Enter the Correct Username and Password')
        end
      end
    end
  end
end

