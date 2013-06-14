module Visit
  class Manage
    class << self

      def log(msg)
        Rails.logger.debug "AMHERE: Rails: #{$0}: #{msg}"
        puts "AMHERE: puts: #{$0}: #{msg}"
      end

    end
  end
end
