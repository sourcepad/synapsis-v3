# SynapsisV3

Ruby wrapper to the SynapsePay API

## Running the Gem

    Synapsis.configure do |config|
      config.client_id = 'YOUR CLIENT ID'
      config.client_secret = 'YOUR CLIENT SECRET'
      config.environment = 'YOUR ENVIRONMENT--defaults to test, set to "production" to access the production URL'
      config.logging = true # false by default, logs request and response data when set to true
    end

## Running the tests

    To run tests, sign up for a SynapsePay account, and create a spec/config-test.yml with a client_id and a client_secret.
