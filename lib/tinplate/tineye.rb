module Tinplate
  class TinEye
    SORTS  = ["score", "size", "crawl_date"]
    ORDERS = ["asc", "desc"]

    def search(image_url: nil, offset: 0, limit: 100, sort: "score", order: "desc")
      raise ArgumentError.new("You must supply an image_url") if !image_url
      raise ArgumentError.new("sort must be one of #{SORTS.join(', ')}") if !SORTS.include?(sort)
      raise ArgumentError.new("order must be one of #{ORDERS.join(', ')}") if !ORDERS.include?(order)

      response = request "search", image_url: image_url, offset: offset.to_s, limit: limit.to_s, sort: sort, order: order
      Tinplate::SearchResults.new(response["results"])
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