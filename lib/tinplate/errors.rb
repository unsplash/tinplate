module Tinplate
  class Error < StandardError
    def self.from_response(code, messages)
      return UnauthorizedError.new(messages.first) if code == 403

      messages.each do |message|
        klass = class_from_message(message)
        return klass.new(messages.join("\n")) if klass
      end

      Tinplate::Error.new(messages.join("\n"))
    end

    def self.class_from_message(message)
      case message
        when /503 Service Unavailable/          then Tinplate::ServiceUnavailableError
        when /service is busy due to high load/ then Tinplate::ServiceUnavailableError
        when /Image too simple/                 then Tinplate::NoSignatureError
        when /purchase another bundle/          then Tinplate::NoCreditsRemainingError
        when /Could not download/               then Tinplate::InaccessibleURLError
        when /Please supply an image/           then Tinplate::InvalidSearchError
        when /Error reading image data/         then Tinplate::InvalidImageDataError
        when /Too many concurrent requests/     then Tinplate::TooManyRequestsError
      end
    end
  end

  class ServiceUnavailableError < Error; end
  class NoSignatureError < Error; end
  class NoCreditsRemainingError < Error; end
  class UnauthorizedError < Error; end
  class InaccessibleURLError < Error; end
  class InvalidSearchError < Error; end
  class InvalidImageDataError < Error; end
  class TooManyRequestsError < Error; end
end
