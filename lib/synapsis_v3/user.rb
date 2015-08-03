class Synapsis::User < Synapsis::APIResource
  extend Synapsis::APIOperations::Create

  def self.create(params)
    payload = params.merge(
      "client" => {
        "client_id" => Synapsis.client_id,
        "client_secret" => Synapsis.client_secret
      }
    )

    response = create_request(payload)
    return_response(response)
  end
end

