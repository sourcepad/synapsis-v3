class Synapsis::Node < Synapsis::APIResource
  extend Synapsis::APIOperations::Create

  # Synapse uses the same endpoint for other Synapse accounts, Account/Routing number, Bank Login, Wire-US, Wire-INT
  # <Synapsis::Response nodes=[#<Synapsis::Response _id=#<Synapsis::Response $oid="55bf217b86c2734342eccfe3">, allowed="CREDIT-AND-DEBIT", extra=#<Synapsis::Response supp_id=nil>, info=#<Synapsis::Response access_token="not_found", account_num="6789", balance=#<Synapsis::Response amount="70.69", currency="USD">, bank_name="bofa", class="CHECKING", name_on_account="Sample User", nickname="LIFEGREEN CHECKING F", routing_num="0017", type="PERSONAL">, is_active=true, type="ACH-US">], success=true>
  def self.add(params)
    add_node_url = "#{API_V3_PATH}node/add"
    response = request(:post, add_node_url, params)
    return_response(response)
  end
end

