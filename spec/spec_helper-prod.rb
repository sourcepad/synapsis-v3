# Include this for specs where you need to test against a production Synapse acount. This is because of the inconsisten behavior between the sandbox and production.

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'synapsis_v3'

require 'yaml'
require 'json'
require 'faker'
require 'pry'

# Require helpers
Dir["./spec/support/**/*.rb"].each { |f| require f }

Synapsis.configure do |config|
  config.environment = 'production'
  config.logging = true
end

if File.file?("./spec/config-#{Synapsis.environment}.yml")
  config_vars = YAML.load_file("./spec/config-#{Synapsis.environment}.yml")
else
  config_vars = {}
end

Synapsis.configure do |config|
  config.client_id = config_vars['client_id']
  config.client_secret = config_vars['client_secret']
end

RSpec.configure do |config|
  config.order = 'random'
end
