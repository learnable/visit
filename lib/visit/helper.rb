module Visit
  class Helper
    class << self
      def log(msg)
        Rails.logger.debug "AMHERE: Rails: #{$0}: #{msg}"
        puts "AMHERE: puts: #{$0}: #{msg}"
      end

      def random_token(length = Visit::Event::TOKEN_LENGTH)
        SecureRandom.base64(length).slice(0, length)
      end
    end
  end
end
