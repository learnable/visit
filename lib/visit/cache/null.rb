module Visit
  class Cache
    class Null < Cache
      def initialize
        super
      end

      def fetch(key, options = {})
        yield
      end

      protected

      def key(prefix, value)
        nil
      end
    end
  end
end
