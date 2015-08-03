class Synapsis::User < Synapsis::APIResource
  extend Synapsis::APIOperations::Create

  def self.create(params)
    payload = params.merge(client_credentials)

    response = create_request(payload)
    return_response(response)
  end

  def self.sign_in(params)
    sign_in_url = "#{API_V3_PATH}#{class_name}/signin"

    payload = params.merge(client_credentials)

    response = request(:post, sign_in_url, payload)
    return_response(response)
  end
end
