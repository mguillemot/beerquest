module Paypal
  class ApiCall
    def initialize
      @params = []
    end

    def add_param(name, value)
      @params << [name, value]
    end

    def send_request
      url = URI.parse(PAYPAL_API_URL)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(url.path)
      response = http.request(request, request_body)
      @response = {}
      response.body.split('&').each do |enc|
        n, v = enc.split('=')
        @response[n] = CGI.unescape(v)
      end
    end

    def response
      @response
    end

    def request_body
      encoded_params = []
      @params.each do |n, v|
        encoded_params << "#{n}=#{CGI.escape(v)}"
      end
      encoded_params.join('&')
    end
  end
end