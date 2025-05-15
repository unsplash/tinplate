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
      img = image_url ? { image_url: image_url } : { image_path: image_path }

      response = request("search", options.merge(img))

      Tinplate::SearchResults.new(response)
    end

    def remaining_searches
      results = request("remaining_searches")["results"]

      bundles = results["bundles"].map do |bundle|
        OpenStruct.new(remaining_searches: bundle["remaining_searches"],
                       start_date:  Time.parse(bundle["start_date"]),
                       expire_date: Time.parse(bundle["expire_date"]))
      end

      OpenStruct.new(total_remaining_searches: results["total_remaining_searches"], bundles: bundles)
    end

    def image_count
      request("image_count")["results"]
    end

    private

    def request(action, params = {})
      http_verb = :get

      upload = if params[:image_path]
        http_verb = :post
        Faraday::Multipart::FilePart.new(params.delete(:image_path), "image/jpeg")
      end

      params.merge!(image_upload: upload) if upload

      headers = { "x-api-key" => Tinplate.configuration.private_key }

      response = connection.send(http_verb, "#{action}/", params, headers)
      response = ::JSON.parse(response.body)

      if response["code"] != 200
        raise Tinplate::Error.from_response(response["code"], response["messages"])
      end

      response
    end

    def connection
      @conn ||= Faraday.new(url: "https://api.tineye.com/rest/") do |faraday|
        faraday.request :multipart
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end

  end

end
