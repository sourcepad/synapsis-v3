class Synapsis::Subscription < Synapsis::APIResource
  def self.create(params)
    add_subscription_url = "#{API_V3_PATH}/subscription/add"

    response = request(:post, add_subscription_url, params.merge(client_credentials))
    return_response(response)
  end

  def self.show(params)
    show_subscription_url = "api/3/subscriptions/#{params[:id]}"

    response = request(:get, show_subscription_url, params)
    return_response(response)
  end

  def self.update(params)
    update_subscription_url = "api/3/subscriptions/#{params[:id]}"

    response = request(:patch, update_subscription_url, params.merge(client_credentials))
    return_response(response)
  end
end

