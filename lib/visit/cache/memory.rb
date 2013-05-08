module Visit
  class Cache
    class Memory < Cache
      def initialize
        @cache = {}
      end

      def fetch(key, options = {})
        if !cache.has_key?(key)
          cache[key] = yield
        end
        cache[key]
      end

      def clear
        @cache = {}
      end
    end
  end
end
