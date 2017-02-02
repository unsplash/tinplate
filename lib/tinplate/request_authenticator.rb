# https://services.tineye.com/developers/tineyeapi/authentication.html

require "securerandom"
require "uri"

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

    def verb
      @image_name ? "POST" : "GET"
    end

    def content_type
      @verb == "GET" ? "" : "multipart/form-data; boundary=-----------RubyMultipartPost"
      #@verb == "GET" ? "" : "multipart/form-data; boundary=d8b4f160da95---------------d8b4f160da95"
    end

    def signature_components
      s= [
        Tinplate.configuration.private_key,
        verb,
        content_type,
        URI.encode_www_form_component(@image_name).downcase,
        @date.to_i,
        @nonce,
        "https://api.tineye.com/rest/#{@action}/",
        hash_to_sorted_query_string(@params),
      ]
      #binding.pry
      s
    end

    def signature
      puts "CORRECT STRING: vibaHBXwUXFqVSg-+kTrqYJZEJkbVeqLc=bo.LlXPOSTmultipart/form-data; boundary=d8b4f160da95---------------d8b4f160da95tineye+logo%281%29.png1350511031wAqXrSG7mJPn5YA6cwDalG.Shttps://api.tineye.com/rest/search/limit=30&offset=0"
      puts "     MY STRING: #{signature_components.join}"

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