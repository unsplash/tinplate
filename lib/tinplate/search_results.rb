module Tinplate
  class SearchResults < OpenStruct
    def initialize(data)
      super total_backlinks: data["total_backlinks"],
            total_results:   data["total_results"],
            matches:         parsed_matches(data["matches"])
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