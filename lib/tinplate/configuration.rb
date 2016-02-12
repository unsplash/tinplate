module Tinplate # :nodoc:
  class Configuration # :nodoc:
    attr_accessor :public_key
    attr_accessor :private_key
    attr_writer   :test

    def initialize
      @test = true
    end

    def test?
      !!@test
    end

  end
end