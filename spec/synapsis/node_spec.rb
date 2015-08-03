require 'spec_helper'

RSpec.describe Synapsis::Node do
  context '.add' do
    context 'ACH account with bank login' do
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
  end
end
