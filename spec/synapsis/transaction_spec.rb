require 'spec_helper'

RSpec.describe Synapsis::Transaction do
  context '.add' do
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
      it 'returns the correct transaction details' do
        add_transaction_response = Synapsis::Transaction.add(add_transaction_params)

        expect(add_transaction_response.success).to be_truthy
        expect(add_transaction_response.trans._id.send(:$oid)).not_to be_nil
        expect(add_transaction_response.trans.amount.amount).to eq add_transaction_params[:trans][:amount][:amount]
        expect(add_transaction_response.trans.timeline.first.status).to eq Synapsis::Transaction::Status::CREATED
        expect(add_transaction_response.trans.to.id.send(:$oid)).to eq SampleReceiver.bank_id
      end
    end

    context 'errors' do
      it 'wrong password raises a Synapsis Error' do
        wrong_transaction_params = add_transaction_params.clone
        wrong_transaction_params[:login][:oauth_key] = 'WRONG PASSWORD'
        expect { Synapsis::Transaction.add(wrong_transaction_params) }.to raise_error(Synapsis::Error).with_message('Incorrect oauth_key/fingerprint')
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

