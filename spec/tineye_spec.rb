require "spec_helper"

describe Tinplate::TinEye do
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
    pending
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