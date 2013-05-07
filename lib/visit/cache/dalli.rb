module Visit
  class Cache
    class Dalli < Cache
      def initialize(cache)
        super cache
      end

      def fetch(key, options = {})
        if cache
          cache.fetch(key, options) do
            yield
          end
        else
          yield
        end
      end

      def clear
        cache.clear
      end
    end
  end
end
