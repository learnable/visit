module Visit
  module HasTemporaryCache
    def temporary_cache_setup
      if Configurable.cache.instance_of? Visit::Cache::Null
        @original_cache = Configurable.cache
        Configurable.cache = Visit::Cache::Memory.new
      else
        @original_cache = nil
      end
    end

    def temporary_cache_teardown
      if !@original_cache.nil?
        Configurable.cache = @original_cache
        @original_cache = nil
      end
    end
  end
end
