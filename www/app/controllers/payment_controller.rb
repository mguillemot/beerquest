class PaymentController < FacebookController

  def donate
    level    = params[:level].to_i
    donation = @me.donations.create(:level => level)
    logger.info "Starting new PayPal payment for donation #{donation.id}..."
    response = Paypal::Api.set_express_checkout(donation, "#{BeerQuest::FB_APP_URL}#{end_donate_path(donation)}", "#{BeerQuest::FB_APP_URL}#{support_us_url}")
    response.log(logger)
    if response.success
      logger.info "SetExpressCheckout success, token is #{response.token}"
      donation.paypal_token = response.token
      if donation.save
        url = PAYPAL_USER_URL + "&token=#{CGI.escape(response.token)}&useraction=commit"
        redirect_to url
      else
        logger.error "Impossible to save transaction info into the donation object (id=#{donation.id})"
        redirect_to home_url
      end
    else
      logger.error "SetExpressCheckout error (code #{response.error_code}): #{response.error_message}"
      redirect_to home_url
    end
  end

  def end
    @donation         = @me.donations.get! params[:id]
    received_token    = params[:token]
    received_payer_id = params[:PayerID]
    logger.info "Checking donation #{@donation.id} on PayPal side..."
    details           = Paypal::Api.get_express_checkout_details(received_token)
    details.log(logger)
    if details.success
      if details.token != received_token || details.token != @donation.paypal_token
        logger.error "PayPal returned with a token (#{details.token}) different from the one saved into donation #{@donation.id} (#{@donation.paypal_token}) or received in the URL (#{received_token})"
        redirect_to home_url
      elsif details.payer_id != received_payer_id
        logger.error "PayPal returned with a PayerID (#{details.payer_id}) different from the one received in the URL (#{received_payer_id})"
        redirect_to home_url
      else
        @donation.paypal_name           = details.name
        @donation.paypal_email          = details.email
        @donation.paypal_payer_id       = received_payer_id
        @donation.paypal_correlation_id = details.correlation_id
        @donation.paypal_amount         = details.amount
        @donation.paypal_currency       = details.currency
        @donation.status                = Donation::STATUS_AUTHORIZED
        if @donation.save
          checkout = Paypal::Api::do_express_checkout_payment(@donation)
          if checkout.success
            @donation.status = Donation::STATUS_OK
            @donation.save
          else
            logger.error "Error during payment checkout of donation #{donation.id}: #{checkout.inspect}"
            redirect_to home_url
          end
        else
          logger.error "Impossible to save transaction completion into the donation object (id=#{donation.id})"
          redirect_to home_url
        end
      end
    else
      logger.error "GetExpressCheckout error (code #{response.error_code}): #{response.error_message}"
      redirect_to home_url
    end
  end

end
