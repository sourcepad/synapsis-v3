require 'spec_helper'

RSpec.describe Synapsis::Node do
  context '.add and .verify' do
    context 'ACH account with bank login, no MFA' do
      let(:add_node_via_bank_login_params) {{
        login: { oauth_key: SampleUser.oauth_consumer_key },
        user: { fingerprint: SampleUser.fingerprint },
        node: {
          type: 'ACH-US',
          info: {
            bank_id: 'synapse_nomfa',
            bank_pw: 'test1234',
            bank_name: 'bofa'
          },
          extra: {
            supp_id: '123sa'
          }
        }
      }}

      context 'happy path' do
        it 'works' do
          add_node_via_bank_login_response = Synapsis::Node.add(add_node_via_bank_login_params)
          expect(add_node_via_bank_login_response.success).to be_truthy
          expect(add_node_via_bank_login_response.nodes.first._id.send(:$oid)).not_to be_nil
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

    context 'ACH account with bank login, with MFA' do
      let(:add_node_via_bank_login_params) {{
        login: { oauth_key: SampleUser.oauth_consumer_key },
        user: { fingerprint: SampleUser.fingerprint },
        node: {
          type: 'ACH-US',
          info: {
            bank_id: 'synapse_code',
            bank_pw: 'test1234',
            bank_name: 'bofa'
          },
          extra: {
            supp_id: '123sa'
          }
        }
      }}

      context 'happy path' do
        it 'works' do
          add_node_via_bank_login_with_mfa_response = Synapsis::Node.add(add_node_via_bank_login_params)
          expect(add_node_via_bank_login_with_mfa_response.success).to be_truthy
          expect(add_node_via_bank_login_with_mfa_response.nodes.first._id.send(:$oid)).not_to be_nil

          verify_node_via_mfa_params = {
            login: { oauth_key: SampleUser.oauth_consumer_key },
            user: { fingerprint: SampleUser.fingerprint },
            node: {
              _id: {
                '$oid' => add_node_via_bank_login_with_mfa_response.nodes.first._id.send(:$oid)
              },
              verify: {
                mfa: 'test_answer'
              }
            }
          }

          verify_node_via_mfa_response = Synapsis::Node.verify(verify_node_via_mfa_params)
          expect(verify_node_via_mfa_response.success).to be_truthy
          expect(verify_node_via_mfa_response.nodes.first.allowed).to eq 'CREDIT-AND-DEBIT'
        end
      end
    end

    context 'ACH account with account & routing number' do
      let(:add_node_via_account_number_params) {{
        login: { oauth_key: SampleUser.oauth_consumer_key },
        user: { fingerprint: SampleUser.fingerprint },
        node: {
          type: 'ACH-US',
          info: {
            nickname: 'Savings Account',
            name_on_account: 'Sankaet Pathak',
            account_num: '123567443',
            routing_num: '051000017',
            type: Synapsis::Node::AccountType::PERSONAL,
            class: Synapsis::Node::AccountClass::CHECKING
          },
          extra: {
            supp_id: '123sa'
          }
        }
      }}

      context 'happy path with add and verify' do
        it 'sets the status of the node to be CREDIT-AND-DEBIT' do
          add_node_via_account_number_response = Synapsis::Node.add(add_node_via_account_number_params)

          expect(add_node_via_account_number_response.success).to be_truthy
          expect(add_node_via_account_number_response.nodes.first._id.send(:$oid)).not_to be_nil

          verify_node_via_account_number_params = {
            login: { oauth_key: SampleUser.oauth_consumer_key },
            user: { fingerprint: SampleUser.fingerprint },
            node: {
              _id: {
                '$oid' => add_node_via_account_number_response.nodes.first._id.send(:$oid)
              },
              verify: {
                micro: [0.1, 0.1]
              }
            }
          }

          verify_node_via_account_number_response = Synapsis::Node.verify(verify_node_via_account_number_params)

          expect(verify_node_via_account_number_response.success).to be_truthy
          expect(verify_node_via_account_number_response.nodes.first.allowed).to eq 'CREDIT-AND-DEBIT'
        end
      end

      context 'errors' do
        xit 'supposedly fails, but invalid account/routing numbers still go through' do
          wrong_account_number_bank_params = add_node_via_account_number_params.clone
          wrong_account_number_bank_params[:node][:info][:routing_number] = 'NOT A ROUTING NUMBER'
          expect { Synapsis::Node.add(wrong_account_number_bank_params) }.to raise_error(Synapsis::Error).with_message('Please Enter the Correct Username and Password')
        end
      end
    end
  end
end
