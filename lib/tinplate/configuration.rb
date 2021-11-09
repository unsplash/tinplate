module Tinplate # :nodoc:
  class Configuration # :nodoc:

    # https://services.tineye.com/developers/tineyeapi/sandbox.html
    SANDBOX_PRIVATE_KEY = "6mm60lsCNIB,FwOWjJqA80QZHh9BMwc-ber4u=t^"

    attr_writer :private_key
    attr_writer :test

    def initialize
      @test = true
    end

    def test?
      !!@test
    end

    def private_key
      test? ? SANDBOX_PRIVATE_KEY : @private_key
    end

  end
end
