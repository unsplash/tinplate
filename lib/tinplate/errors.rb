module Tinplate
  class Error < StandardError
    attr_reader :code
    attr_reader :type
    attr_reader :message

    def initialize(code, type, message)
      @code = code
      @type = @type
      @message = message
    end
  end
end