class Synapsis::Error < StandardError
  attr_reader :error_code, :http_code, :error, :success

  def initialize(error_code:, http_code:, error:, success:)
    @error = error
    @http_code = http_code
    @error_code = error_code
    @success = success
  end
end
