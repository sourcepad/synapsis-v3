class UserFactory
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
        'fingerprint' => 'suasusau21324redakufejfjsf'
      ],
      ips: [
        '192.168.0.1'
      ]
    }

    return Synapsis::User.create(user_params)
  end
end
