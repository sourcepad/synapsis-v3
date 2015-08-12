module Synapsis::APIOperations::Show
  def show_request(params)
    request(:post, show_url, params)
  end

  def show_url
    "#{API_V3_PATH}#{class_name}/show"
  end
end

