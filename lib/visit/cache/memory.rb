module Visit
  class Cache
    class Memory < Cache
      def initialize
        @memory_cache = {}
        super @memory_cache
      end

      def fetch(key, options = {})
        if !cache.has_key?(key)
          cache[key] = yield
        end
        cache[key]
      end

      def clear
        @memory_cache = {}
      end
    end
  end
end
