require 'mime/types'
require 'base64'

class Synapsis::User < Synapsis::APIResource
  extend Synapsis::APIOperations::Create

  module DocumentStatus
    MISSING_INVALID = 'MISSING|INVALID'
    RESUBMIT_INVALID = 'RESUBMIT|INVALID'
    SUBMITTED = 'SUBMITTED'
    SUBMITTED_REVIEWING = 'SUBMITTED|REVIEWING'
    SUBMITTED_MFA_PENDING = 'SUBMITTED|MFA_PENDING'
    SUBMITTED_INVALID = 'SUBMITTED|INVALID'
    SUBMITTED_VALID = 'SUBMITTED|VALID'
  end

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

  def self.add_document(payload, headers)
    verify_kyc_new_url = "#{API_V3_NEW_PATH}users/#{headers[:synapse_id]}"

    # Automatically convert all physical documents to base64 format
    physical_doc_array = payload[:documents][0][:physical_docs]
    physical_doc_array = convert_all_physical_documents_to_base64(physical_doc_array)

    response = request(:patch, verify_kyc_new_url, payload, headers)

    return_response(response)
  end

  def self.convert_all_physical_documents_to_base64(docs_array)
    if docs_array
      docs_array.map do |doc|
        doc[:document_value] = convert_attachment_to_base_64(doc[:document_value])
      end
    end
  end

  def self.show(payload, headers)
    show_user_url = "#{API_V3_NEW_PATH}#{class_name_pluralized}/#{headers[:synapse_id]}"

    response = request(:get, show_user_url, payload, headers)

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

  def self.convert_attachment_to_base_64(doc)
    file_type = MIME::Types.type_for(doc).first.content_type

    if file_type == 'text/plain'
      mime_padding = "data:text/csv;base64,"
    else
      mime_padding = "data:#{file_type};base64,"
    end

    return "#{mime_padding}#{Base64.encode64(File.open(doc, 'rb') { |f| f.read })}"
  end

  private_class_method :convert_all_physical_documents_to_base64
  private_class_method :convert_attachment_to_base_64
end

