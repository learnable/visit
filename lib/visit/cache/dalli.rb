module Visit
  class Cache
    class Dalli < Cache
      def initialize(cache)
        super cache
      end

      def has_key?(key)
        raise "expected Cache::key" unless key.instance_of? Visit::Cache::Key

        @cache.exist?(key.to_s)
      end

      def fetch(key, options = {})
        if cache
          raise "expected Cache::key" unless key.instance_of? Visit::Cache::Key

          cache.fetch(key.to_s, options) do
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
