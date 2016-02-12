module Tinplate
  class TinEye


    private

    def base_url
      Tinplate.configuration.test? ? "http://api.tineye.com/rest/" : "https://tineye.com/probably"
    end

  end

end