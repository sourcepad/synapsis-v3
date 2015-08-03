$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'synapsis_v3'

require 'yaml'
require 'json'
require 'faker'
require 'pry'

# Require helpers
Dir["./spec/support/**/*.rb"].each { |f| require f }

config_vars = YAML.load_file('./spec/config.yml')

Synapsis.configure do |config|
  config.client_id = config_vars['client_id']
  config.client_secret = config_vars['client_secret']
  config.environment = 'test'
end

RSpec.configure do |config|
  config.order = 'random'
end
