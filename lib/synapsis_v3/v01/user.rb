require 'mime/types'
require 'base64'

class Synapsis::V01::User < Synapsis::APIResource
  extend Synapsis::APIOperations::Create

  def self.add_kyc(payload)
    add_kyc_v1_url = "#{API_V3_PATH}#{class_name}/doc/add"

    response = request(:post, add_kyc_v1_url, payload)
    return_response(response)
  end

  def self.verify_kyc(payload)
    verify_kyc_v1_url = "#{API_V3_PATH}#{class_name}/doc/verify"

    response = request(:post, verify_kyc_v1_url, payload)
    return_response(response)
  end

  def self.add_document(payload)
    add_document_v1_url = "#{API_V3_PATH}#{class_name}/doc/attachments/add"

    response = request(:post, add_document_v1_url, convert_attachment_to_base_64(payload))
    return_response(response)
  end

  # Replace attachment in the params
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

  private_class_method :convert_attachment_to_base_64
end

