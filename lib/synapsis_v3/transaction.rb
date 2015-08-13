class Synapsis::Transaction < Synapsis::APIResource
  extend Synapsis::APIOperations::Show

  module Status
    QUEUED_BY_SYNAPSE = 'QUEUED-BY-SYNAPSE'
    QUEUED_BY_RECEIVER = 'QUEUED-BY-RECEIVER'
    CREATED = 'CREATED'
    PROCESSING_DEBIT = 'PROCESSING-DEBIT'
    PROCESSING_CREDIT = 'PROCESSING-CREDIT'
    SETTLED = 'SETTLED'
    CANCELED = 'CANCELED'
    RETURNED = 'RETURNED'
  end

  # Synapse uses the same endpoint for other Synapse accounts, Account/Routing number, Bank Login, Wire-US, Wire-INT
  # Add via bank username/password
  # <Synapsis::Response nodes=[#<Synapsis::Response _id=#<Synapsis::Response $oid="55bf217b86c2734342eccfe3">, allowed="CREDIT-AND-DEBIT", extra=#<Synapsis::Response supp_id=nil>, info=#<Synapsis::Response access_token="not_found", account_num="6789", balance=#<Synapsis::Response amount="70.69", currency="USD">, bank_name="bofa", class="CHECKING", name_on_account="Sample User", nickname="LIFEGREEN CHECKING F", routing_num="0017", type="PERSONAL">, is_active=true, type="ACH-US">], success=true>
  # Add via account number/routing number
  # <Synapsis::Response nodes=[#<Synapsis::Response _id=#<Synapsis::Response $oid="55bf275586c2734342eccfed">, allowed="CREDIT", extra=#<Synapsis::Response supp_id="123sa">, info=#<Synapsis::Response account_num="7443", class="CHECKING", name_on_account="Sankaet Pathak", nickname="Savings Account", routing_num="0017", type="PERSONAL">, is_active=true, type="ACH-US">], success=true>

  def self.add(params)
    add_transaction_url = "#{API_V3_PATH}trans/add"

    response = request(:post, add_transaction_url, params)
    return_response(response)
  end

  def self.cancel(params)
    cancel_transaction_url = "#{API_V3_PATH}trans/cancel"

    response = request(:post, cancel_transaction_url, params)
    return_response(response)
  end

  def self.class_name
    'trans'
  end
end

