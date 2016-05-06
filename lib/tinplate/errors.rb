module Tinplate
  class Error < StandardError
    def self.from_response(code, type, message)
      klass = case message
              when /503 Service Unavailable/          then Tinplate::ServiceUnavailableError
              when /service is busy due to high load/ then Tinplate::ServiceUnavailableError
              when /Image too simple/                 then Tinplate::NoSignatureError
              when /purchase another bundle/          then Tinplate::NoCreditsRemainingError
              else
                Tinplate::Error
              end

      klass.new(message)
    end
  end

  class ServiceUnvailableError < Error; end
  class NoSignatureError < Error; end
  class NoCreditsRemainingError < Error; end
end