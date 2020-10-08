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

  let(:no_signature_error_response) do
    {
      stats: {
        timestamp: "1331923111.71",
        query_time: "0.51"
      },
      code:     500,
      messages: ["NO_SIGNATURE_ERROR", "Image too simple or too small to create unique signature."],
      results:  []
    }.to_json
  end

  describe "#search" do
    let(:valid_response) do
      <<-JSON
        {
          "stats": {
            "timestamp": "1488909217.20",
            "query_time": "4.74",
            "total_backlinks": 26135,
            "total_collection": 57,
            "total_results": 6683,
            "total_stock": 4,
            "total_filtered_results": 6683
          },
          "code": 200,
          "messages": [],
          "results": {
            "matches": [
              {
                "domain": "designerstalk.com",
                "backlinks": [
                  {
                    "url": "http://www.cybersalt.org/images/funnypictures/cats/catmelonhead.jpg",
                    "crawl_date": "2015-03-18",
                    "backlink": "http://www.designerstalk.com/forums/tv-film/67944-dredd-2012-a-post904441.html"
                  },
                  {
                    "url": "http://www.cybersalt.org/images/funnypictures/cats/catmelonhead.jpg",
                    "crawl_date": "2015-07-09",
                    "backlink": "http://www.designerstalk.com/forums/tv-film/67944-dredd-2012-a-post888204.html"
                  },
                  {
                    "url": "http://www.cybersalt.org/images/funnypictures/cats/catmelonhead.jpg",
                    "crawl_date": "2015-03-20",
                    "backlink": "http://www.designerstalk.com/forums/tv-film/67944-dredd-2012-a-post887253.html"
                  },
                  {
                    "url": "http://www.cybersalt.org/images/funnypictures/cats/catmelonhead.jpg",
                    "crawl_date": "2015-03-11",
                    "backlink": "http://www.designerstalk.com/forums/tv-film/67944-dredd-2012-a-last-post.html"
                  },
                  {
                    "url": "http://www.cybersalt.org/images/funnypictures/cats/catmelonhead.jpg",
                    "crawl_date": "2015-03-11",
                    "backlink": "http://www.designerstalk.com/forums/tv-film/67944-dredd-2012-a.html"
                  }
                ],
                "format": "JPEG",
                "filesize": 239481,
                "overlay": "overlay/dca08fc6b2ec4b9e04f94a4e29223f6af3dd6555/ba97680a685da25e5910b8cb95d6e9680be1fab360a0daad8a8a537ab992948f?m21=-4.63347e-05&m22=0.999952&m23=0.00784483&m11=0.999952&m13=0.00137017&m12=4.63347e-05",
                "height": 451,
                "width": 531,
                "image_url": "http://img.tineye.com/result/ba97680a685da25e5910b8cb95d6e9680be1fab360a0daad8a8a537ab992948f",
                "query_hash": "dca08fc6b2ec4b9e04f94a4e29223f6af3dd6555",
                "top_level_domain": "designerstalk.com",
                "tags": [],
                "size": 239481
              },
              {
                "domain": "reddit.com",
                "backlinks": [
                  {
                    "url": "http://www.cybersalt.org/images/funnypictures/cats/catmelonhead.jpg",
                    "crawl_date": "2016-07-16",
                    "backlink": "https://www.reddit.com/r/OldAsTheNet/"
                  },
                  {
                    "url": "https://i.imgur.com/s69Vo.jpg",
                    "crawl_date": "2016-03-24",
                    "backlink": "https://www.reddit.com/r/RoastMe/comments/3j7e80/i_fuel_myself_on_the_roasts_of_the_many/"
                  }
                ],
                "format": "JPEG",
                "filesize": 239481,
                "overlay": "overlay/dca08fc6b2ec4b9e04f94a4e29223f6af3dd6555/ba97680a685da25e5910b8cb95d6e9680be1fab360a0daad8a8a537ab992948f?m21=-4.63347e-05&m22=0.999952&m23=0.00784483&m11=0.999952&m13=0.00137017&m12=4.63347e-05",
                "height": 451,
                "width": 531,
                "image_url": "http://img.tineye.com/result/ba97680a685da25e5910b8cb95d6e9680be1fab360a0daad8a8a537ab992948f",
                "query_hash": "dca08fc6b2ec4b9e04f94a4e29223f6af3dd6555",
                "top_level_domain": "reddit.com",
                "tags": [],
                "size": 239481
              }
            ]
          }
        }
      JSON
    end

    it "parses results from URL search" do
      connection = double(get: double(body: valid_response))
      allow(tineye).to receive(:connection).and_return(connection)

      results = tineye.search(image_url: "http://example.com/photo.jpg")
      stats = {
        timestamp:              "1488909217.20",
        query_time:             "4.74",
        total_backlinks:        26135,
        total_collection:       57,
        total_results:          6683,
        total_stock:            4,
        total_filtered_results: 6683
      }

      expect(results.stats.to_h).to eq stats
      expect(results.matches.count). to eq 2
      expect(results.matches.first.tags).to be_an Array
      expect(results.matches.first.backlinks.first).to be_a OpenStruct
    end

    it "parses results from upload search" do
      path = "/home/jim/example.jpg"

      connection = double(post: double(body: valid_response))
      upload = double(original_filename: "example.jpg")

      allow(tineye).to receive(:connection).and_return(connection)
      allow(Faraday::UploadIO).to receive(:new).with(path, "image/jpeg").and_return upload

      results = tineye.search(image_path: path)

      expect(results.stats.total_results).to eq 6683
      expect(results.stats.total_backlinks).to eq 26135
      expect(results.matches.count).to eq 2

      expect(results.matches.first.backlinks.first).to be_a OpenStruct
    end

    context "when the API returns an error" do
      it "raises a generic error by default" do
        connection = double(get: double(body: error_response))
        allow(tineye).to receive(:connection).and_return(connection)
        expect {
          tineye.search(image_url: "http://example.com/photo.jpg")
        }.to raise_error(Tinplate::Error)
      end

      it "raises a NoSignatureError" do
        connection = double(get: double(body: no_signature_error_response))
        allow(tineye).to receive(:connection).and_return(connection)
        expect {
          tineye.search(image_url: "http://example.com/photo.jpg")
        }.to raise_error(Tinplate::NoSignatureError)
      end
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

  describe "#remaining_searches" do
    let(:valid_response) do
      <<-JSON
        {
          "stats": {
            "timestamp": "1490029267.12",
            "query_time": "0.07"
          },
          "code": 200,
          "messages": [],
          "results": {
            "bundles": [
              {
                "remaining_searches": 719,
                "start_date": "2016-12-17 03:42:50 UTC",
                "expire_date": "2018-12-17 03:42:50 UTC"
              },
              {
                "remaining_searches": 10000,
                "start_date": "2017-02-25 16:31:09 UTC",
                "expire_date": "2019-02-25 16:31:09 UTC"
              },
              {
                "remaining_searches": 10000,
                "start_date": "2017-03-19 09:50:16 UTC",
                "expire_date": "2019-03-19 09:50:16 UTC"
              }
            ],
            "total_remaining_searches": 20719
          }
        }
      JSON
    end

    it "returns parsed object" do
      connection = double(get: double(body: valid_response))
      allow(tineye).to receive(:connection).and_return(connection)

      remaining = tineye.remaining_searches
      expect(remaining.bundles.first.remaining_searches).to eq 719
      expect(remaining.bundles.first.start_date).to  eq Time.parse("2016-12-17 03:42:50 UTC")
      expect(remaining.bundles.first.expire_date).to eq Time.parse("2018-12-17 03:42:50 UTC")
      expect(remaining.total_remaining_searches).to eq 20719
    end

    it "raises on non-200 response" do
      connection = double(get: double(body: error_response))
      allow(tineye).to receive(:connection).and_return(connection)
      expect {
        tineye.remaining_searches
      }.to raise_error(Tinplate::Error)
    end
  end

  describe "#image_count" do
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
