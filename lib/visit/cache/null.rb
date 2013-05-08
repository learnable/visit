module Visit
  class Cache
    class Null < Cache
      def initialize
        super
      end

      def fetch(key, options = {})
        yield
      end

      def clear
      end
    end
  end
end
