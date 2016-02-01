require 'spec_helper'

RSpec.describe Synapsis::Subscription do
  let(:add_subscription_params) {{
    url: 'http://requestb.in/15k15qr1',
    scope: [
      "USERS|POST",
      "NODES|POST",
      "TRANS|POST",
    ]
  }}

  context '.create' do
    context 'happy path' do
      it 'creates a subscription' do
        add_subscription_response = Synapsis::Subscription.create(add_subscription_params)

        expect(add_subscription_response.subscription._id.send(:$oid)).not_to be_nil
      end
    end
  end

  context '.show' do
    context 'happy path' do
      xit 'shows the subscription status' do
        add_subscription_response = Synapsis::Subscription.create(add_subscription_params)
        add_id = add_subscription_response.subscription._id.send(:$oid)

        show_subscription_params = {
          id: add_id
        }

        update_subscription_response = Synapsis::Subscription.show(show_subscription_params)
      end
    end
  end

  context '.update' do
    context 'happy path' do
      xit 'updates the transaction' do
        add_subscription_response = Synapsis::Subscription.create(add_subscription_params)
        add_id = add_subscription_response.subscription._id.send(:$oid)

        update_subscription_url = add_subscription_response = add_subscription_response.subscription.url

        update_subscription_params = {
          is_active: false,
          id: add_id
        }

        update_subscription_response = Synapsis::Subscription.update(update_subscription_params)
      end
    end
  end
end

