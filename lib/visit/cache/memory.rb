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

      def fetch(key, options = {})
        raise "expected Cache::Key" unless key.instance_of? Visit::Cache::Key

        k = key.to_s

        is_hit = true

        if !has_key? key
          is_hit = false

          @cache[k] = yield
        end

        # Helper.log "AMHERE: cache: id: #{@cache.object_id} key: #{k} #{is_hit ? 'hit' : 'miss'} returns: #{@cache[k].to_s}" if k =~ /robot/i
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
