module Visit
  class Configurable
    class << self

      def labels
        throw_exception
      end

      def ignorable
        throw_exception
      end

      private

      def throw_exception
        begin
          raise RuntimeError, "Visit::Configurable - expected this to be overridden by config/initializers'"
        rescue => e
          # TODO: put this back in
          #CrashLog.notify e
          puts e.to_s
        end
      end

    end
  end
end
