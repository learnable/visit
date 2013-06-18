module Visit
  class Cache
    class Null < Cache
      def initialize
        super
      end

      def delete(key)
      end

      def has_key?(key)
        raise_if_not_key(key)

        false
      end

      def fetch(key, options = {})
        yield
      end

      def clear
      end
    end
  end
end
