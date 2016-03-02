require 'spec_helper'

RSpec.describe Synapsis::Transaction do
  before(:all) do
    @oauth_token = UserFactory.create_user.oauth.oauth_key
    @bank_id = UserFactory.create_node(
      oauth_token: @oauth_token,
      fingerprint: UserFactory.default_fingerprint
    ).nodes.first._id.send(:$oid)

    @receiver_oauth_token = UserFactory.create_user.oauth.oauth_key
    @receiver_bank_id = UserFactory.create_node(
      oauth_token: @receiver_oauth_token,
      fingerprint: UserFactory.default_fingerprint
    ).nodes.first._id.send(:$oid)
  end

  context '.add and .cancel' do
    let(:add_transaction_params) {{
      login: { oauth_key: @oauth_token },
      user: { fingerprint: UserFactory.default_fingerprint },
      trans: {
        to: {
          type: 'ACH-US',
          id: @receiver_bank_id
        },
        from: {
          type: 'ACH-US',
          id: @bank_id
        },
        extra: {
          ip: '192.168.0.1'
        },
        amount: {
          amount: 10.10,
          currency: 'USD'
        }
      }
    }}

    context 'happy path' do
      it 'returns the correct transaction details, then cancels the transaction' do
        add_transaction_response = Synapsis::Transaction.add(add_transaction_params)

        expect(add_transaction_response.success).to be_truthy
        expect(add_transaction_response.trans._id.send(:$oid)).not_to be_nil
        expect(add_transaction_response.trans.amount.amount).to eq add_transaction_params[:trans][:amount][:amount]
        expect(add_transaction_response.trans.timeline.first.status).to eq Synapsis::Transaction::Status::CREATED
        expect(add_transaction_response.trans.to.id.send(:$oid)).to eq @receiver_bank_id

        cancel_transaction_params = {
          login: { oauth_key: @oauth_token },
          user: { fingerprint: UserFactory.default_fingerprint },
          trans: {
            _id: {
              '$oid' => add_transaction_response.trans._id.send(:$oid)
            }
          }
        }

        cancel_transaction_response = Synapsis::Transaction.cancel(cancel_transaction_params)

        expect(cancel_transaction_response.success).to be_truthy
        expect(cancel_transaction_response.message.en).to eq 'Transaction has been canceled.'
      end
    end

    context 'errors' do
      context '.add' do
        it 'wrong password raises a Synapsis Error' do
          wrong_transaction_params = add_transaction_params.clone
          wrong_transaction_params[:login][:oauth_key] = 'WRONG PASSWORD'
          expect { Synapsis::Transaction.add(wrong_transaction_params) }.to raise_error(Synapsis::Error).with_message('Badly formatted payload. Please fix the payload and try again. Error: ValueError: Invalid value supplied for key "oauth_key". Explanation: The supplied data is incorrect. Please check the docs to make sure that you are sending the value in the correct format.')
        end
      end


      context '.cancel' do
        xit 'pending--you can\'t cancel a SETTLED transaction' do
        end
      end
    end
  end

  # This is when we want to send money from a bank account to a Synapse account
  context '.add ACH to Synapse' do
    before(:all) do
      show_node_params = {
        login: { oauth_key: @receiver_oauth_token },
        user: { fingerprint: UserFactory.default_fingerprint },
        filter: {
          'type' => 'SYNAPSE-US'
        }
      }
      show_node_response = Synapsis::Node.show(show_node_params)
      @receiver_synapse_us_id = show_node_response.nodes.first._id.send(:$oid)
    end

    let(:add_transaction_params) {{
      login: { oauth_key: @oauth_token },
      user: { fingerprint: UserFactory.default_fingerprint },
      trans: {
        to: {
          type: 'SYNAPSE-US',
          id: @receiver_synapse_us_id
        },
        from: {
          type: 'ACH-US',
          id: @bank_id
        },
        extra: {
          ip: '192.168.0.1'
        },
        amount: {
          amount: 10.10,
          currency: 'USD'
        }
      }
    }}

    #<Synapsis::Response success=true, trans=#<Synapsis::Response _id=#<Synapsis::Response $oid="55d1b31f86c2736bd9172aba">, amount=#<Synapsis::Response amount=10.1, currency="USD">, client=#<Synapsis::Response id=854, name="Daryll Santos">, extra=#<Synapsis::Response created_on=#<Synapsis::Response $date=1439806239190>, ip="192.168.0.1", latlon="0,0", note="", other=#<Synapsis::Response>, process_on=#<Synapsis::Response $date=1439806239190>, supp_id="", webhook="">, fees=[#<Synapsis::Response fee=0.25, note="Synapse Facilitator Fee", to=#<Synapsis::Response id=#<Synapsis::Response $oid="559339aa86c273605ccd35df">>>], from=#<Synapsis::Response id=#<Synapsis::Response $oid="55bf3be186c2735f97979bb9">, nickname="LIFEGREEN CHECKING F", type="ACH-US", user=#<Synapsis::Response _id=#<Synapsis::Response $oid="55bf3b5e86c273627b20ea5f">, legal_names=["Sample Sender"]>>, recent_status=#<Synapsis::Response date=#<Synapsis::Response $date=1439806239190>, note="Transaction created", status="CREATED", status_id="1">, timeline=[#<Synapsis::Response date=#<Synapsis::Response $date=1439806239190>, note="Transaction created", status="CREATED", status_id="1">], to=#<Synapsis::Response id=#<Synapsis::Response $oid="55afa3d686c27312caffa669">, nickname="Default Synapse Node", type="SYNAPSE-US", user=#<Synapsis::Response _id=#<Synapsis::Response $oid="55afa3d686c27312caffa668">, legal_names=["Daryll Santos"]>>>>

    context 'happy path' do
      it 'returns the correct transaction details, then cancels the transaction' do
        add_transaction_response = Synapsis::Transaction.add(add_transaction_params)

        expect(add_transaction_response.success).to be_truthy
        expect(add_transaction_response.trans._id.send(:$oid)).not_to be_nil
        expect(add_transaction_response.trans.amount.amount).to eq add_transaction_params[:trans][:amount][:amount]
        expect(add_transaction_response.trans.timeline.first.status).to eq Synapsis::Transaction::Status::CREATED
        expect(add_transaction_response.trans.to.id.send(:$oid)).to eq @receiver_synapse_us_id
      end
    end
  end


  context '.show' do
    let(:view_transaction_params) {{
      login: { oauth_key: @oauth_token },
      user: { fingerprint: UserFactory.default_fingerprint }
    }}

    context 'happy path' do
      context 'no filter' do
        it 'shows all transactions' do
          view_transaction_response = Synapsis::Transaction::show(view_transaction_params)
          expect(view_transaction_response.success).to be_truthy
          expect(view_transaction_response.trans).to be_a_kind_of(Array)
        end
      end

      context 'filter based on $oid' do
        xit 'PENDING--filter does not work on hashes--shows all transactions' do
          view_transaction_params = {
            login: { oauth_key: @oauth_token },
            user: { fingerprint: UserFactory.default_fingerprint },
            'filter' => {
              'page' => 1
            }
          }
          view_transaction_response = Synapsis::Transaction::show(view_transaction_params)

          expect(view_transaction_response.success).to be_truthy
          expect(view_transaction_response.trans).to be_a_kind_of(Array)
        end
      end
    end
  end
end

