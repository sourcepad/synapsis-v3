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

