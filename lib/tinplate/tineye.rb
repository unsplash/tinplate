module Tinplate
  class TinEye

    def search(image_url: nil, offset: 0, limit: 30)
      image_url ||= "http://www.tineye.com/images/Tineye%20Logo.png"
      request "search", image_url: image_url, offset: offset.to_s, limit: limit.to_s
    end

    def remaining_searches
    end

    def image_count
      request("image_count")["results"]
    end


    private

    def request(action, params = {})
      params.merge!(authentication_params(action, params))

      response = ::JSON.parse(connection.get("#{action}/", params).body)

      if response["code"] != 200
        raise Tinplate::Error.new(response["code"], response["messages"][0], response["messages"][1])
      end

      response
    end

    def connection
      @conn ||= Faraday.new(url: "http://api.tineye.com/rest/") do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger                
        faraday.adapter  Faraday.default_adapter
      end
    end

    def authentication_params(action, params = {}, image_name = "")

      nonce = SecureRandom.hex
      date  = Time.now.to_i

      sig_components = [
        Tinplate.configuration.private_key,
        "GET",
        "", # Content-Type for GET requests is blank
        URI.encode(image_name).downcase,
        date,
        nonce,
        "http://api.tineye.com/rest/#{action}/",
        hash_to_sorted_query_string(params),
      ]

      {
        api_key: Tinplate.configuration.public_key,
        api_sig: signature(sig_components),
        nonce:   nonce,
        date:    date
      }
    end

    def signature(components)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"),
                              Tinplate.configuration.private_key,
                              components.join)
    end

    def hash_to_sorted_query_string(params)
      Hash[params.sort].map do |key, value|
        "#{key}=#{URI.encode_www_form_component(value)}"
      end.join("&")
    end

    


  end

end