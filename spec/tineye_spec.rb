require "spec_helper"

describe Tinplate::TinEye do
  # The valid responses here are all taken straight from the API doc examples at:
  # https://services.tineye.com/developers/tineyeapi/overview.html


  let(:tineye) { Tinplate::TinEye.new }
  let(:error_response) do
    {
      stats: {
        timestamp: "1331923111.71",
        query_time: "0.51"
      },
      code:     400,
      messages: ["API_ERROR", "Couldn't download URL, caught exception: HTTPError()"],
      results:  []
    }.to_json
  end

  describe "#search" do
    let(:valid_response) do
      {
        stats: {
          timestamp:  "1259096177.74",
          query_time: "2.46"
        },
        code:     200,
        messages: [],
        results: {
          total_backlinks: 3,
          total_results: 2,
          matches: [
            {
              width: 400,
              image_url: "http://images.tineye.com/result/0f1e84b7b7538e8e7de048f4d45eb8f579e3e999941b3341ed9a754eb447ebb1",
              backlinks: [
                {
                  url: "http://weblogs.newsday.com/features/home/cheap_thrills_blog/stripey-yarnDIY-thumb.jpeg",
                  crawl_date: "2012-06-30",
                  backlink: "http://weblogs.newsday.com/features/home/cheap_thrills_blog/2007/05/"
                }
              ],
              format: "JPEG",
              overlay: "overlay/507bb6bf9a397284e2330be7c0671aadc7319b4b/0f1e84b7b7538e8e7de048f4d45eb8f579e3e999941b3341ed9a754eb447ebb1?m21=-9.06952e-05&m22=0.999975&m23=0.0295591&m11=0.999975&m13=-0.0171177&m12=9.06952e-05",
              contributor: true,
              size: 50734,
              height: 300
            },
            {
              width: 180,
              image_url: "http://images.tineye.com/result/0dd198eed842082619fe783e73bfd2c9291522d973ad64b871e605530b817800",
              backlinks: [
                {
                  url: "http://photos3.meetupstatic.com/photos/event/a/7/2/5/global_5622789.jpeg",
                  crawl_date: "2012-06-30",
                  backlink: "http://www.meetup.com/geneva-meetup/calendar/11331213/"
                },
                { 
                  url: "http://photos3.meetupstatic.com/photos/event/a/7/2/5/global_5622789.jpeg",
                  crawl_date: "2012-06-29",
                  backlink: "http://www.meetup.com/geneva-meetup/calendar/11316812/"
                }
              ],
              format: "JPEG",
              overlay: "overlay/507bb6bf9a397284e2330be7c0671aadc7319b4b/0dd198eed842082619fe783e73bfd2c9291522d973ad64b871e605530b817800?m21=0.00156478&m22=2.21849&m23=-0.0262089&m11=2.21849&m13=0.254416&m12=-0.00156478",
              contributor: false,
              size: 10010,
              height: 135
            }
          ]
        }
      }.to_json
    end

    it "parses results" do
      connection = double(get: double(body: valid_response))
      allow(tineye).to receive(:connection).and_return(connection)

      results = tineye.search(image_url: "http://example.com/photo.jpg")
      expect(results.total_results).to eq 2
      expect(results.total_backlinks).to eq 3
      expect(results.matches.count). to eq 2

      expect(results.matches.first.backlinks.first).to be_a OpenStruct
    end

    it "raises on non-200 response" do
      connection = double(get: double(body: error_response))
      allow(tineye).to receive(:connection).and_return(connection)
      expect {
        tineye.search(image_url: "http://example.com/photo.jpg")
      }.to raise_error(Tinplate::Error)
    end

    it "errors without an image_url parameter" do
      expect {
        tineye.search
      }.to raise_error(ArgumentError)
    end

    it "errors with invalid sort option" do
      expect {
        tineye.search(image_url: "http://example.com/photo.jpg", sort: "wholeheartedly")
      }.to raise_error(ArgumentError)
    end

    it "errors with invalid order option" do
      expect {
        tineye.search(image_url: "http://example.com/photo.jpg", order: "backwards")
      }.to raise_error(ArgumentError)
    end
  end

  describe "remaining_searches" do
    let(:valid_response) do
      {
        stats: {
          timestamp: "1250535183.20",
          query_time: "0.01"
        },
        code:     200,
        messages: [],
        results: {
          remaining_searches: 24998,
          start_date:  "2009-09-18 16:01:49 UTC",
          expire_date: "2009-11-02 16:01:49 UTC"
        }
      }.to_json
    end

    it "returns parsed object" do
      connection = double(get: double(body: valid_response))
      allow(tineye).to receive(:connection).and_return(connection)
      
      remaining = tineye.remaining_searches
      expect(remaining.remaining_searches).to eq 24998
      expect(remaining.start_date).to  eq DateTime.parse("2009-09-18 16:01:49 UTC")
      expect(remaining.expire_date).to eq DateTime.parse("2009-11-02 16:01:49 UTC")
    end

    it "raises on non-200 response" do
      connection = double(get: double(body: error_response))
      allow(tineye).to receive(:connection).and_return(connection)
      expect {
        tineye.remaining_searches
      }.to raise_error(Tinplate::Error)
    end
  end

  describe "image_count" do
    let(:valid_response) do
      {
        stats: {
          timestamp:  "1250524846.03",
          query_time: "0.00"
        },
        code:     200,
        messages: [],
        results:  1109463092
      }.to_json
    end

    it "returns the number of images" do
      connection = double(get: double(body: valid_response))
      allow(tineye).to receive(:connection).and_return(connection)
      expect(tineye.image_count).to eq 1109463092
    end

    it "raises on non-200 response" do
      connection = double(get: double(body: error_response))
      allow(tineye).to receive(:connection).and_return(connection)
      expect {
        tineye.image_count
      }.to raise_error(Tinplate::Error)
    end

  end
end