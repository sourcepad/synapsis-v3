# Used in Transactions
module SampleReceiver
  class << self
    def email
      'synapsis_receiver@sourcepad.com'
    end

    def name_first
      'Synapsis'
    end

    def name_last
      'Receiver'
    end

    def oauth_consumer_key
      'x38JnlHHf4p1bAs8ZRerQUMuzBmgHo8pb6VNoenZ'
    end

    def refresh_token # You need this to access their account in Synapse
      'XcnODdHjm1ZyGniZpjbS6r5TYZzhOEPAZEEEiBUq'
    end

    def fingerprint
      'suasusau21324redakufejfjsf'
    end

    def bank_id # Bank $oid
      '55bf36f286c2735f97979bb7'
    end
  end
end
