module Tinplate
  class TinEye

    def search(image_url: nil, offset: 0, limit: 30)
      image_url ||= "http://www.tineye.com/images/Tineye%20Logo.png"
      request "search", image_url: image_url, offset: offset.to_s, limit: limit.to_s
    end

    def remaining_searches
      results = request("remaining_searches")["results"]
      OpenStruct.new(remaining_searches: results["remaining_searches"],
                     start_date:  DateTime.parse(results["start_date"]),
                     expire_date: DateTime.parse(results["expire_date"]))
    end

    def image_count
      request("image_count")["results"]
    end


    private

    def request(action, params = {})
      auth = Tinplate::RequestAuthenticator.new(action, params)
      params.merge!(auth.params)

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

  end

end