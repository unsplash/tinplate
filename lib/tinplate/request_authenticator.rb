# https://services.tineye.com/developers/tineyeapi/authentication.html

require "securerandom"
require "uri"
require "openssl"

module Tinplate
  class RequestAuthenticator

    def initialize(action, params = {}, image_name = "")
      @action = action
      @params = params
      @image_name = image_name || ""
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

    def verb
      @image_name.empty? ? "GET" : "POST"
    end

    def content_type
      verb == "GET" ? "" : "multipart/form-data; boundary=-----------RubyMultipartPost"
    end

    def signature_components
      [
        Tinplate.configuration.private_key,
        verb,
        content_type,
        URI.encode_www_form_component(@image_name).downcase,
        @date.to_i,
        @nonce,
        "https://api.tineye.com/rest/#{@action}/",
        hash_to_sorted_query_string(@params),
      ]
    end

    def signature
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
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