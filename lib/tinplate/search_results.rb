module Tinplate
  class SearchResults < OpenStruct
    def initialize(data)
      super stats:   OpenStruct.new(data["stats"]),
            matches: parsed_matches(data["results"]["matches"])
    end

    private

    def parsed_matches(matches_data)
      matches_data.map do |match|
        backlinks = { backlinks: match["backlinks"].map { |links| OpenStruct.new(links) } }
        OpenStruct.new(match.merge(backlinks))
      end
    end
  end
end