module Tinplate
  class Error < StandardError
    def self.from_response(code, type, message)
      klass = case message
              when /503 Service Unavailable/          then Tinplate::ServiceUnavailable
              when /service is busy due to high load/ then Tinplate::ServiceUnavailable
              when /Image too simple/                 then Tinplate::NoSignatureError
              when /purchase another bundle/          then Tinplate::NoCreditsRemaining
              else
                Tinplate::Error
              end

      klass.new(message)
    end
  end

  class ServiceUnvailable < Error; end
  class NoSignatureError < Error; end
  class NoCreditsRemaining < Error; end
end