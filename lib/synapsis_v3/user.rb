require 'mime/types'
require 'base64'

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

  def self.refresh(params)
    return sign_in(params)
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

  def self.show(params)
    show_user_url = "#{API_V3_PATH}#{class_name}/client/users"

    response = request(:post, show_user_url, params.merge(client_credentials))

    return_response(response)
  end

  def self.show_kyc(params)
    show_kyc_url = "#{API_V3_PATH}#{class_name}/kyc/show"

    response = request(:post, show_kyc_url, params.merge(client_credentials))

    return_response(response)
  end

  def self.search(params)
    search_user_url = "#{API_V3_PATH}#{class_name}/search"

    response = request(:post, search_user_url, params.merge(client_credentials))

    return_response(response)
  end

  private

  def self.convert_attachment_to_base_64(doc_params)
    file_type = MIME::Types.type_for(doc_params[:user][:doc][:attachment]).first.content_type

    if file_type == 'text/plain'
      mime_padding = "data:text/csv;base64,"
    else
      mime_padding = "data:#{file_type};base64,"
    end

    doc_params[:user][:doc][:attachment] = "#{mime_padding}#{Base64.encode64(File.open(doc_params[:user][:doc][:attachment], 'rb') { |f| f.read })}"

    return doc_params
  end
end

