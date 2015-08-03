# Used in Transactions
module SampleSender
  class << self
    def email
      'sample_sender@sourcepad.com'
    end

    def name_first
      'Sample'
    end

    def name_last
      'Sender'
    end

    def oauth_consumer_key
      '9exjIoS4pHOhTZQ3XSuj4CrLlXHdW9cXshQfhOdH'
    end

    def refresh_token # You need this to access their account in Synapse
      'uAsGV1sO9PkEp8piWKCLOCCO8yUwxGJEy7xD6TmV'
    end

    def fingerprint
      'suasusau21324redakufejfjsf'
    end

    def bank_id # Bank $oid
      '55bf3be186c2735f97979bb9'
    end
  end
end
