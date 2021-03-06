require 'faraday'
require 'faraday/detailed_logger'
require 'ostruct'

# Namespacing
module Synapsis
  module APIOperations; end
  module V01; end
end

require "synapsis_v3/version"
require "synapsis_v3/api_resource"
require "synapsis_v3/api_operations/create"
require "synapsis_v3/api_operations/show"
require "synapsis_v3/error"
require "synapsis_v3/user"
require "synapsis_v3/node"
require "synapsis_v3/transaction"
require "synapsis_v3/subscription"
require "synapsis_v3/v01/user"

API_V3_PATH = 'api/v3/'
API_V3_NEW_PATH = 'api/3/'

module Synapsis
  class << self
    attr_accessor :client_id, :client_secret, :environment, :logging

    def connection
      @connection ||= Faraday.new(url: synapse_url) do |faraday|
        faraday.request  :multipart              # form-encode POST params

        if Synapsis.logging
          faraday.response  :detailed_logger        # form-encode POST params
        end

        faraday.request  :url_encoded            # form-encode POST params
        faraday.response :logger                 # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter # make requests with Net::HTTP
      end
    end

    def synapse_url
      if environment == 'production'
        'https://synapsepay.com/'
      else
        'https://sandbox.synapsepay.com/'
      end
    end

    def configure(&params)
      yield(self)
    end
  end

  class Response < OpenStruct; end
end
