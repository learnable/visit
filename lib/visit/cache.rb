module Visit
  class Cache
    def initialize(cache = nil)
      @cache = cache
    end

    def has_key?(key)
        ret = true
        fetch(key) { ret = false }
        ret
    end

    protected

    def cache
      @cache
    end
  end
end
