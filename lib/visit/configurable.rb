module Visit
  class Configurable
    class << self

      def labels
        throw_exception
      end

      def ignorable
        throw_exception
      end

      def throw_exception
        begin
          raise RuntimeError, "Visit::Configurable - expected this to be overridden by config/initializers'"
        rescue => e
          CrashLog.notify e
        end
      end

    end
  end
end
