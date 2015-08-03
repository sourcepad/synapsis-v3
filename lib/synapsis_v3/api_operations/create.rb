module Synapsis::APIOperations::Create
  def create_request(params)
    request(:post, create_url, params)
  end

  def create_url
    "#{API_V3_PATH}#{class_name}/create"
  end
end

