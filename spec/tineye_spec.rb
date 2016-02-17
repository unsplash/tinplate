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
    pending
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