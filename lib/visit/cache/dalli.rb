module Visit
  class Cache
    class Dalli < Cache
      def initialize(cache)
        super cache
      end

      def delete(key)
        cache.delete key
      end

      def has_key?(key)
        raise_if_not_key key

        @cache.exist? key.to_s
      end

      def fetch(key, options = nil)
        raise_if_not_key key

        cache.fetch(key.to_s, options) { yield }
      end

      def clear
        cache.clear
      end
    end
  end
end
