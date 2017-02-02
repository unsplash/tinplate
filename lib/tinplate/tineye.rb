module Tinplate
  class TinEye
    SORTS  = ["score", "size", "crawl_date"]
    ORDERS = ["asc", "desc"]

    def search(image_path: nil, image_url: nil, offset: 0, limit: 100, sort: "score", order: "desc")
      raise ArgumentError.new("You must supply an image or image_url") if !image_url && !image_path
      raise ArgumentError.new("sort must be one of #{SORTS.join(', ')}") if !SORTS.include?(sort)
      raise ArgumentError.new("order must be one of #{ORDERS.join(', ')}") if !ORDERS.include?(order)

      options = {
        offset: offset.to_s,
        limit: limit.to_s,
        sort: sort,
        order: order
      }

      response = if image_url
        get_request "search", options.merge(image_url: image_url)
      elsif image_path
        post_request "search", options.merge(image_path: image_path)
      end

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

    def get_request(action, params = {})
      auth = Tinplate::RequestAuthenticator.new(action, params)
      params.merge!(auth.params)

      response = ::JSON.parse(connection.get("#{action}/", params).body)

      if response["code"] != 200
        raise Tinplate::Error.from_response(response["code"], response["messages"][0], response["messages"][1])
      end

      response
    end

    def post_request(action, params = {})
      image = params.delete(:image_path)

      auth = Tinplate::RequestAuthenticator.new(action, params, image)
      params.merge!(auth.params)

      params.merge!(image_upload: Faraday::UploadIO.new(image, "image/jpeg"))

      response = ::JSON.parse(connection.post("#{action}/", params).body)

      response
    end

    def connection
      @conn ||= Faraday.new(url: "https://api.tineye.com/rest/") do |faraday|
        faraday.request  :multipart
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
      end
    end

  end

end
