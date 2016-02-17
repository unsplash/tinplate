# https://services.tineye.com/developers/tineyeapi/authentication.html

module Tinplate
  class RequestAuthenticator

    def initialize(action, params = {}, image_name = "")
      @action = action
      @params = params
      @image_name = image_name
      @nonce = SecureRandom.hex
      @date  = Time.now.to_i
    end

    def params
      {
        api_key: Tinplate.configuration.public_key,
        api_sig: signature,
        nonce:   @nonce,
        date:    @date
      }
    end

    def signature_components
      [
        Tinplate.configuration.private_key,
        "GET",
        "", # Content-Type for GET requests is blank
        URI.encode(@image_name).downcase,
        @date.to_i,
        @nonce,
        "http://api.tineye.com/rest/#{@action}/",
        hash_to_sorted_query_string(@params),
      ]
    end

    def signature
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"),
                              Tinplate.configuration.private_key,
                              signature_components.join)
    end

    def hash_to_sorted_query_string(params)
      Hash[params.sort].map do |key, value|
        "#{key}=#{URI.encode_www_form_component(value)}"
      end.join("&")
    end
  end
end