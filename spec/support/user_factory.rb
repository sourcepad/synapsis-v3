class UserFactory
  def self.default_authentication_headers(synapse_user_create_response)
    {
      fingerprint: UserFactory.default_fingerprint,
      synapse_id: synapse_user_create_response.user._id.send(:$oid),
      oauth_key: synapse_user_create_response.oauth.oauth_key,
      ip_address: UserFactory.default_ip_address
    }
  end

  def self.default_ip_address
    '192.168.0.1'
  end

  def self.default_fingerprint
    'fingerprint'
  end

  def self.create_user
    user_params = {
      logins: [
        email: 'synapsis_kyc_spec@sourcepad.com',
        password: '5ourcep4d',
        read_only: false
      ],
      phone_numbers: [
        '901.111.1111'
      ],
      legal_names: [
        'Synapsis KYCSpec'
      ],
      fingerprints: [
        'fingerprint' => self.default_fingerprint
      ],
      ips: [
        '192.168.0.1'
      ]
    }

    return Synapsis::User.create(user_params)
  end

  def self.kyc_user(oauth_token:, fingerprint:)
    add_kyc_params = {
      login: {
        oauth_key: oauth_token
      },
      user: {
        doc: {
          birth_day: 4,
          birth_month: 2,
          birth_year: 1940,
          name_first: 'Sample',
          name_last: 'KYCSpec',
          address_street1: '1 Infinate Loop',
          address_postal_code: '95014',
          address_country_code: 'US',
          document_value: '2222',
          document_type: 'SSN'
        },
        fingerprint: fingerprint
      }
    }
    Synapsis::User.add_kyc(add_kyc_params)

    photo_path = 'spec/support/test_photo.jpg'

    doc_params = {
      login: {
        oauth_key: oauth_token
      },
      user: {
        doc: {
          attachment: photo_path
        },
        fingerprint: fingerprint
      }
    }

    doc = Synapsis::User.add_document(doc_params)
  end

  def self.create_node(oauth_token:, fingerprint:)
    create_node_params = {
      login: { oauth_key: oauth_token },
      user: { fingerprint: fingerprint },
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
    }
    return Synapsis::Node.add(create_node_params)
  end
end
