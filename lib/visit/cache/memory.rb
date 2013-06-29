module Visit
  class Cache
    class Memory < Cache
      def initialize
        @cache = {}
      end

      def delete(key)
        cache.delete key.to_s
      end

      def has_key?(key)
        raise_if_not_key key

        @cache.has_key? key.to_s
      end

      def fetch(key, options = nil)
        raise_if_not_key key

        k = key.to_s

        @cache[k] = yield if !has_key? key

        @cache[k]
      end

      def to_h
        @cache
      end

      def clear
        @cache = {}
      end
    end
  end
end
