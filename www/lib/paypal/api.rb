module Paypal
  class Api
    def self.set_express_checkout(order, return_url, cancel_url)
      call = ApiCall.new
      call.add_param 'USER', PAYPAL_USER
      call.add_param 'PWD', PAYPAL_PWD
      call.add_param 'SIGNATURE', PAYPAL_SIGNATURE
      call.add_param 'METHOD', 'SetExpressCheckout'
      call.add_param 'VERSION', '56.0'
      call.add_param 'PAYMENTACTION', 'Sale'
      call.add_param 'NOSHIPPING', '1'
      call.add_param 'LOCALECODE', (I18n.locale == 'fr') ? 'FR' : 'US'
      call.add_param 'CURRENCYCODE', order.currency.paypal_code
      call.add_param 'RETURNURL', return_url
      call.add_param 'CANCELURL', cancel_url
      order.order_items.each_with_index do |oi,i|
        call.add_param "L_NAME#{i}", oi.item.title
        call.add_param "L_AMT#{i}", '%.2f' % oi.unit_price
        call.add_param "L_QTY#{i}", "#{oi.quantity}"
      end
      call.add_param 'ITEMAMT', '%.2f' % order.items_total_price
      call.add_param 'SHIPPINGAMT', '%.2f' % order.shipping_price
      call.add_param 'AMT', '%.2f' % (order.items_total_price + order.shipping_price)
      call.add_param 'ALLOWNOTE', '1'
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

    def self.do_express_checkout_payment(order)
      call = ApiCall.new
      call.add_param 'USER', PAYPAL_USER
      call.add_param 'PWD', PAYPAL_PWD
      call.add_param 'SIGNATURE', PAYPAL_SIGNATURE
      call.add_param 'METHOD', 'DoExpressCheckoutPayment'
      call.add_param 'VERSION', '56.0'
      call.add_param 'PAYMENTACTION', 'Sale'
      call.add_param 'TOKEN', order.paypal_token
      call.add_param 'PAYERID', order.paypal_payer_id
      order.order_items.each_with_index do |oi,i|
        call.add_param "L_NAME#{i}", oi.item.title
        call.add_param "L_AMT#{i}", '%.2f' % oi.unit_price
        call.add_param "L_QTY#{i}", "#{oi.quantity}"
      end
      call.add_param 'ITEMAMT', '%.2f' % order.items_total_price
      call.add_param 'SHIPPINGAMT', '%.2f' % order.shipping_price
      call.add_param 'AMT', '%.2f' % (order.items_total_price + order.shipping_price)
      call.add_param 'CURRENCYCODE', order.currency.paypal_code
      call.send_request
      DoExpressCheckoutPayment.new call.response
    end
  end
end