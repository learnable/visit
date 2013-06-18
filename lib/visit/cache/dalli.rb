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
