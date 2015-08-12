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

  def self.add_kyc(params)
    add_kyc_url = "#{API_V3_PATH}#{class_name}/doc/add"

    response = request(:post, add_kyc_url, params)
    return_response(response)
  end

  def self.verify_kyc(params)
    verify_kyc_url = "#{API_V3_PATH}#{class_name}/doc/verify"

    response = request(:post, verify_kyc_url, params)
    return_response(response)
  end

  def self.add_document(params)
    add_document_url = "#{API_V3_PATH}user/doc/attachments/add"

    response = request(:post, add_document_url, convert_attachment_to_base_64(params))

    return_response(response)
  end

  private

  def self.convert_attachment_to_base_64(doc_params)
    doc_params[:user][:doc][:attachment] = "data:text/csv;base64,#{Base64.encode64(File.open(doc_params[:user][:doc][:attachment], 'rb') { |f| f.read })}"

    return doc_params
  end
end

