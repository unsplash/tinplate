require "spec_helper"

describe Tinplate::RequestAuthenticator do
  let(:date)  { Time.parse("2016-02-17T15:35:02-06:00") }
  let(:nonce) { "ABCD1234" }

  context "without image_name (i.e. GET request)" do
    let(:sig)   { "3fff4830af34042a3e98a9d45e45e80694f864a6ee4abef7934a3f2c4d20d287" }

    let(:authenticator) do
      auth = Tinplate::RequestAuthenticator.new("image_count", { offset: 1, limit: 2 })
      auth.instance_variable_set(:@date, date)
      auth.instance_variable_set(:@nonce, nonce)
      auth
    end

    it "has correct signature components" do
      components = [
        "6mm60lsCNIB,FwOWjJqA80QZHh9BMwc-ber4u=t^",
        "GET",
        "",
        "",
        date.to_i,
        nonce,
        "https://api.tineye.com/rest/image_count/",
        "limit=2&offset=1",
      ]
      expect(authenticator.signature_components).to eq components
    end

    it "generates correct signature" do
      expect(authenticator.signature).to eq sig
    end

    it "sorts hashes by key" do
      params = { b: "moo", a: "zoo", c: "cow" }
      expect(authenticator.hash_to_sorted_query_string(params)).to eq "a=zoo&b=moo&c=cow"
    end

    it "gives correct auth parameters" do
      params = {
        api_key: "LCkn,2K7osVwkX95K4Oy",
        api_sig: sig,
        nonce:   nonce,
        date:    date
      }
      expect(authenticator.params).to eq params
    end
  end

  context "with image_name (i.e. POST request)" do
    let(:sig)   { "780bf5b105520ad7bd79aae72994e8d03828dead813a49d2f70f83a461221bd0" }

    let(:authenticator) do
      auth = Tinplate::RequestAuthenticator.new("search", { offset: 1, limit: 2 }, "Pretty Image.jpg")
      auth.instance_variable_set(:@date, date)
      auth.instance_variable_set(:@nonce, nonce)
      auth
    end

    it "has correct signature components" do
      components = [
        "6mm60lsCNIB,FwOWjJqA80QZHh9BMwc-ber4u=t^",
        "POST",
        "multipart/form-data; boundary=-----------RubyMultipartPost",
        "pretty+image.jpg",
        date.to_i,
        nonce,
        "https://api.tineye.com/rest/search/",
        "limit=2&offset=1",
      ]
      expect(authenticator.signature_components).to eq components
    end

    it "generates correct signature" do
      expect(authenticator.signature).to eq sig
    end

    it "sorts hashes by key" do
      params = { b: "moo", a: "zoo", c: "cow" }
      expect(authenticator.hash_to_sorted_query_string(params)).to eq "a=zoo&b=moo&c=cow"
    end

    it "gives correct auth parameters" do
      params = {
        api_key: "LCkn,2K7osVwkX95K4Oy",
        api_sig: sig,
        nonce:   nonce,
        date:    date
      }
      expect(authenticator.params).to eq params
    end
  end
end