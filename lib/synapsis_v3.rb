require 'faraday'
require 'ostruct'

# Namespacing
module Synapsis
  module APIOperations; end
end

require "synapsis_v3/version"
require "synapsis_v3/api_resource"
require "synapsis_v3/api_operations/create"
require "synapsis_v3/error"
require "synapsis_v3/user"
require "synapsis_v3/node"
require "synapsis_v3/transaction"

API_V3_PATH = 'api/v3/'

module Synapsis
  class << self
    attr_accessor :client_id, :client_secret, :environment

    def connection
      @connection ||= Faraday.new(url: synapse_url) do |faraday|
        faraday.request  :multipart             # form-encode POST params
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
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
