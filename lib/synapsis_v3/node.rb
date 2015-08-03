class Synapsis::Node < Synapsis::APIResource
  module AccountType
    PERSONAL = 'PERSONAL'
    BUSINESS = 'BUSINESS'
  end

  module AccountClass
    CHECKING = 'CHECKING'
    SAVINGS = 'SAVINGS'
  end

  # Synapse uses the same endpoint for other Synapse accounts, Account/Routing number, Bank Login, Wire-US, Wire-INT
  # Add via bank username/password
  # <Synapsis::Response nodes=[#<Synapsis::Response _id=#<Synapsis::Response $oid="55bf217b86c2734342eccfe3">, allowed="CREDIT-AND-DEBIT", extra=#<Synapsis::Response supp_id=nil>, info=#<Synapsis::Response access_token="not_found", account_num="6789", balance=#<Synapsis::Response amount="70.69", currency="USD">, bank_name="bofa", class="CHECKING", name_on_account="Sample User", nickname="LIFEGREEN CHECKING F", routing_num="0017", type="PERSONAL">, is_active=true, type="ACH-US">], success=true>
  # Add via account number/routing number
  # <Synapsis::Response nodes=[#<Synapsis::Response _id=#<Synapsis::Response $oid="55bf275586c2734342eccfed">, allowed="CREDIT", extra=#<Synapsis::Response supp_id="123sa">, info=#<Synapsis::Response account_num="7443", class="CHECKING", name_on_account="Sankaet Pathak", nickname="Savings Account", routing_num="0017", type="PERSONAL">, is_active=true, type="ACH-US">], success=true>

  def self.add(params)
    add_node_url = "#{API_V3_PATH}node/add"

    response = request(:post, add_node_url, params)
    return_response(response)
  end

  # Verify via MFA
  # <Synapsis::Response nodes=[#<Synapsis::Response _id=#<Synapsis::Response $oid="55bf34aa86c27361bed754ab">, allowed="CREDIT-AND-DEBIT", extra=#<Synapsis::Response supp_id=nil>, info=#<Synapsis::Response access_token="not_found", account_num="6789", balance=#<Synapsis::Response amount="70.69", currency="USD">, bank_name="bofa", class="CHECKING", name_on_account="Sample User", nickname="LIFEGREEN CHECKING F", routing_num="0017", type="PERSONAL">, is_active=true, type="ACH-US">], success=true>
  # Verify via account number/routing number
  # Synapsis::Response nodes=[#<Synapsis::Response _id=#<Synapsis::Response $oid="55bf327d86c27361bed754a9">, allowed="CREDIT-AND-DEBIT", extra=#<Synapsis::Response supp_id="123sa">, info=#<Synapsis::Response account_num="7443", class="CHECKING", name_on_account="Sankaet Pathak", nickname="Savings Account", routing_num="0017", type="PERSONAL">, is_active=true, type="ACH-US">], success=true>
  def self.verify(params)
    verify_node_url = "#{API_V3_PATH}node/verify"

    response = request(:post, verify_node_url, params)
    return_response(response)
  end
end

