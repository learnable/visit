module Visit
  class Cache
    def initialize(cache = nil)
      @cache = cache
    end

    protected

    def raise_if_not_key(key)
      raise "expected Cache::Key" unless key.instance_of? Visit::Cache::Key
    end

    def cache
      @cache
    end
  end
end
