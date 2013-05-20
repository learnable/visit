module Visit
  class Cache
    class Null < Cache
      def initialize
        super
      end

      def has_key?(key)
        raise "expected Cache::Key" unless key.instance_of? Visit::Cache::Key

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
