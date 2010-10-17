# Success content:
#"TAXAMT"=>"0.00",
#"CURRENCYCODE"=>"EUR",
#"SHIPTOCOUNTRYCODE"=>"FR",
#"INSURANCEAMT"=>"0.00",
#"HANDLINGAMT"=>"0.00",
#"BUILD"=>"1105502",
#"SHIPPINGAMT"=>"0.00",
#"TIMESTAMP"=>"2009-11-19T07:09:27Z",
#"LASTNAME"=>"User",
#"ADDRESSSTATUS"=>"Unconfirmed",
#"SHIPTOCITY"=>"Paris",
#"SHIPTONAME"=>"Test User",
#"EMAIL"=>"buyer_1258613811_per@npng.org",
#"VERSION"=>"56.0",
#"COUNTRYCODE"=>"FR",
#"PAYERSTATUS"=>"verified",
#"CORRELATIONID"=>"9fde56adbe282",
#"TOKEN"=>"EC-8FM589019E049503V",
#"AMT"=>"42.00",
#"SHIPTOSTATE"=>"Alsace",
#"SHIPTOSTREET"=>"Av. de la Pelouse, 87648672 Mayet",
#"FIRSTNAME"=>"Test",
#"PAYERID"=>"WXDNBJYQG85QN",
#"ACK"=>"Success",
#"SHIPTOCOUNTRYNAME"=>"France",
#"SHIPTOZIP"=>"75002"

module Paypal
  class GetExpressCheckoutDetails < ApiResponse
    attr_reader :payer_id, :email, :name, :zip, :city, :street, :state, :country_code, :country_name, :note

    def initialize(response)
      super
      @payer_id = response['PAYERID']
      @email = response['EMAIL'] || ''
      @name = response['SHIPTONAME']
      @street = response['SHIPTOSTREET']
      @street += "\n#{response['SHIPTOSTREET2']}" if response['SHIPTOSTREET2']
      @zip = response['SHIPTOZIP']
      @city = response['SHIPTOCITY']
      @state = response['SHIPTOSTATE']
      @country_code = response['SHIPTOCOUNTRYCODE']
      @country_name = response['SHIPTOCOUNTRYNAME']
      @note = response['NOTE']
    end
  end
end