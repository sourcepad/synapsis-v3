class Synapsis::APIResource
  def self.request(method = :post, url, params)

    Synapsis.connection.send(method) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.url url
      req.body = JSON.generate(params)
    end
  end

  def self.class_name
    name.partition('::').last.downcase
  end

  def class_name
    self.class.name.partition('::').last.downcase
  end

  def self.return_response(response)
    parsed_response = JSON.parse(response.body, object_class: Synapsis::Response)

    if response.success?
      return parsed_response
    else
      raise Synapsis::Error.new(
        error: parsed_response.error,
        http_code: parsed_response.http_code,
        error_code: parsed_response.error_code,
        success: parsed_response.success
      )
    end
  end

  def self.parse_as_synapse_resource(response)
    return JSON.parse(response.body, object_class: Synapsis::Response)
  end

  protected

  def self.client_credentials
    {
      "client" => {
        "client_id" => Synapsis.client_id,
        "client_secret" => Synapsis.client_secret
      }
    }
  end
end
