require "spec_helper"

describe Tinplate::RequestAuthenticator do

  let(:date)  { Time.parse("2016-02-17T15:35:02-06:00") }
  let(:nonce) { "ABCD1234" }
  let(:sig)   { "e82fab492c4ddd2ce25c553ec114b22b443e7d11" }

  let(:authenticator) do
    auth = Tinplate::RequestAuthenticator.new("image_count", { offset: 1, limit: 2 }, "Pretty Image.jpg")
    auth.instance_variable_set(:@date, date)
    auth.instance_variable_set(:@nonce, nonce)
    auth
  end

  it "has correct signature components" do
    components = [
      "6mm60lsCNIB,FwOWjJqA80QZHh9BMwc-ber4u=t^",
      "GET",
      "",
      "pretty%20image.jpg",
      date.to_i,
      nonce,
      "http://api.tineye.com/rest/image_count/",
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