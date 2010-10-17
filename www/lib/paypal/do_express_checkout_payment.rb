# Typical success response:
#"TAXAMT"=>"0.00",
#"CURRENCYCODE"=>"EUR",
#"TRANSACTIONTYPE"=>"expresscheckout",
#"TRANSACTIONID"=>"89L87486543870342",
#"BUILD"=>"1105502",
#"PAYMENTTYPE"=>"instant",
#"TIMESTAMP"=>"2009-11-19T07:16:54Z",
#"PENDINGREASON"=>"multicurrency",
#"ORDERTIME"=>"2009-11-19T07:16:54Z",
#"REASONCODE"=>"None",
#"PAYMENTSTATUS"=>"Pending",
#"VERSION"=>"56.0",
#"CORRELATIONID"=>"8bb98c7f7d8f6",
#"TOKEN"=>"EC-3M4765682B9738025",
#"AMT"=>"42.00",
#"ACK"=>"Success"

module Paypal
  class DoExpressCheckoutPayment < ApiResponse
    attr_reader :transaction_id, :payment_status, :pending_reason, :reason_code

    def initialize(response)
      super
      @transaction_id = response['TRANSACTIONID']
      @payment_status = response['PAYMENTSTATUS']
      @pending_reason = response['PENDINGREASON']
      @reason_code = response['REASONCODE']
    end
  end
end