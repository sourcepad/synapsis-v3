require 'spec_helper'

RSpec.describe Synapsis::Transaction do
  context '.add and .cancel' do
    let(:add_transaction_params) {{
      login: { oauth_key: SampleSender.oauth_consumer_key },
      user: { fingerprint: SampleSender.fingerprint },
      trans: {
        to: {
          type: 'ACH-US',
          id: SampleReceiver.bank_id
        },
        from: {
          type: 'ACH-US',
          id: SampleSender.bank_id
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
        expect(add_transaction_response.trans.to.id.send(:$oid)).to eq SampleReceiver.bank_id

        cancel_transaction_params = {
          login: { oauth_key: SampleSender.oauth_consumer_key },
          user: { fingerprint: SampleSender.fingerprint },
          trans: {
            _id: {
              '$oid' => add_transaction_response.trans._id.send(:$oid)
            }
          }
        }

        cancel_transaction_response = Synapsis::Transaction.cancel(cancel_transaction_params)

        expect(cancel_transaction_response.success).to be_truthy
        expect(cancel_transaction_response.message.en).to eq 'Transaction has been canceled'
      end
    end

    context 'errors' do
      context '.add' do
        it 'wrong password raises a Synapsis Error' do
          wrong_transaction_params = add_transaction_params.clone
          wrong_transaction_params[:login][:oauth_key] = 'WRONG PASSWORD'
          expect { Synapsis::Transaction.add(wrong_transaction_params) }.to raise_error(Synapsis::Error).with_message('Incorrect oauth_key/fingerprint')
        end
      end

      context '.cancel' do
        it 'you can\'t cancel a SETTLED transaction' do
          cancel_settled_transaction_params = {
            login: { oauth_key: SampleSender.oauth_consumer_key },
            user: { fingerprint: SampleSender.fingerprint },
            trans: {
              _id: {
                '$oid' => 'ID55c9d68b86c2737915d1de08' # Settled transaction: https://sandbox.synapsepay.com/v3/dashboard/#/transaction/55c9d68b86c2737915d1de08
              }
            }
          }

          expect { Synapsis::Transaction.cancel(cancel_settled_transaction_params) }.to raise_error(Synapsis::Error).with_message('Sorry, this request could not be processed. Please try again later.')
        end
      end
    end
  end

  # This is when we want to send money from a bank account to a Synapse account
  context '.add ACH to Synapse' do
    let(:add_transaction_params) {{
      login: { oauth_key: SampleSender.oauth_consumer_key },
      user: { fingerprint: SampleSender.fingerprint },
      trans: {
        to: {
          type: 'SYNAPSE-US',
          id: SampleSynapseAccount.bank_id
        },
        from: {
          type: 'ACH-US',
          id: SampleSender.bank_id
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
        expect(add_transaction_response.trans.to.id.send(:$oid)).to eq SampleSynapseAccount.bank_id

        cancel_transaction_params = {
          login: { oauth_key: SampleSender.oauth_consumer_key },
          user: { fingerprint: SampleSender.fingerprint },
          trans: {
            _id: {
              '$oid' => add_transaction_response.trans._id.send(:$oid)
            }
          }
        }

        cancel_transaction_response = Synapsis::Transaction.cancel(cancel_transaction_params)

        expect(cancel_transaction_response.success).to be_truthy
        expect(cancel_transaction_response.message.en).to eq 'Transaction has been canceled'
      end
    end
  end


  context '.show' do
    let(:view_transaction_params) {{
      login: { oauth_key: SampleSender.oauth_consumer_key },
      user: { fingerprint: SampleSender.fingerprint }
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
            login: { oauth_key: SampleSender.oauth_consumer_key },
            user: { fingerprint: SampleSender.fingerprint },
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

