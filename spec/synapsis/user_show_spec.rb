require 'spec_helper'
require 'base64'

RSpec.describe Synapsis::User do
  context '#show' do
    xit 'pending--need to figure out which arguments to pass in-- the without an id argument, it shows all users?' do
      show_user_response = Synapsis::User.show({}, {})

      expect(show_user_response._id).to eq 1
    end

    it 'with an ID argument, it shows the user' do
      user = UserFactory.create_user

      show_user_response = Synapsis::User.show({}, {
        fingerprint: UserFactory.default_fingerprint,
        synapse_id: user.user._id.send(:$oid),
        oauth_key: user.oauth.oauth_key
      })

      expect(show_user_response._id).to eq user.user._id.send(:$oid)
    end
  end
end
