module Visit
  module HasTemporaryCache
    def temporary_cache_setup
      if Configurable.cache.instance_of? Visit::Cache::Null
        @temporary_cache_instead_of = Configurable.cache
        Configurable.cache = Visit::Cache::Memory.new
      else
        @temporary_cache_instead_of = nil
      end
    end

    def temporary_cache_teardown
      if @temporary_cache_instead_of
        Configurable.cache = @temporary_cache_instead_of
        @temporary_cache_instead_of = nil
      end
    end
  end
end
