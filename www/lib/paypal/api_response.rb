# Typical error response:
#"L_SEVERITYCODE0"=>"Error",
#"L_ERRORCODE0"=>"10415",
#"BUILD"=>"1105502",
#"TIMESTAMP"=>"2009-11-19T07:17:35Z",
#"L_LONGMESSAGE0"=>"A successful transaction has already been completed for this token.",
#"VERSION"=>"56.0",
#"L_SHORTMESSAGE0"=>"Transaction refused because of an invalid argument. See additional error messages for details.",
#"CORRELATIONID"=>"74c6b48924e9",
#"ACK"=>"Failure"

module Paypal
  class ApiResponse
    attr_reader :success, :warning, :error_message, :error_code, :severity_code, :token, :correlation_id, :timestamp, :version, :build

    def initialize(response)
      case response['ACK']
        when 'Success'
          @success = true
          @warning = false
        when 'SuccessWithWarning'
          @success = true
          @warning = true
        when 'Failure'
          @success = false
          @warning = false
        when 'FailureWithWarning'
          @success = false
          @warning = true
      end
      @error_message = response['L_LONGMESSAGE0']
      @error_code = response['L_ERRORCODE0']
      @severity_code = response['L_SEVERITYCODE0']
      @token = response['TOKEN']
      @correlation_id = response['CORRELATIONID']
      @timestamp = response['TIMESTAMP']
      @version = response['VERSION']
      @build = response['BUILD']
      @full_response = response
    end

    def log(logger)
      logger.info "PaypalApi response of type #{self.class} was #{@full_response.inspect}"
    end
  end
end