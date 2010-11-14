module Paypal
  class Api
    def self.set_express_checkout(donation, return_url, cancel_url)
      call = ApiCall.new
      call.add_param 'USER', PAYPAL_USER
      call.add_param 'PWD', PAYPAL_PWD
      call.add_param 'SIGNATURE', PAYPAL_SIGNATURE
      call.add_param 'METHOD', 'SetExpressCheckout'
      call.add_param 'VERSION', '56.0'
      call.add_param 'NOSHIPPING', '1'
      call.add_param 'LOCALECODE', (I18n.locale == 'fr') ? 'FR' : 'US'
      call.add_param 'RETURNURL', return_url
      call.add_param 'CANCELURL', cancel_url
      call.add_param 'ALLOWNOTE', '0'
      call.add_param 'CURRENCYCODE', donation.currency
      call.add_param 'ITEMAMT', '%.2f' % donation.amount
      call.add_param 'SHIPPINGAMT', '%.2f' % 0
      call.add_param 'AMT', '%.2f' % donation.amount
      call.add_param "L_NAME0", donation.name
      call.add_param "L_DESC0", donation.description
      call.add_param "L_AMT0", '%.2f' % donation.amount
      call.add_param "L_QTY0", "1"
      call.send_request
      SetExpressCheckout.new call.response
    end

    def self.get_express_checkout_details(token)
      call = ApiCall.new
      call.add_param 'USER', PAYPAL_USER
      call.add_param 'PWD', PAYPAL_PWD
      call.add_param 'SIGNATURE', PAYPAL_SIGNATURE
      call.add_param 'METHOD', 'GetExpressCheckoutDetails'
      call.add_param 'VERSION', '56.0'
      call.add_param 'TOKEN', token
      call.send_request
      GetExpressCheckoutDetails.new call.response
    end

    def self.do_express_checkout_payment(donation)
      call = ApiCall.new
      call.add_param 'USER', PAYPAL_USER
      call.add_param 'PWD', PAYPAL_PWD
      call.add_param 'SIGNATURE', PAYPAL_SIGNATURE
      call.add_param 'METHOD', 'DoExpressCheckoutPayment'
      call.add_param 'VERSION', '56.0'
      call.add_param 'TOKEN', donation.paypal_token
      call.add_param 'PAYMENTACTION', 'Sale'
      call.add_param 'PAYERID', donation.paypal_payer_id
      call.add_param 'CURRENCYCODE', donation.currency
      call.add_param 'ITEMAMT', '%.2f' % donation.amount
      call.add_param 'SHIPPINGAMT', '%.2f' % 0
      call.add_param 'AMT', '%.2f' % donation.amount
      call.add_param "L_NAME0", donation.name
      call.add_param "L_DESC0", donation.description
      call.add_param "L_AMT0", '%.2f' % donation.amount
      call.add_param "L_QTY0", "1"
      call.send_request
      DoExpressCheckoutPayment.new call.response
    end
  end
end