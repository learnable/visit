module Visit
  class Cache
    def initialize(cache = nil)
      @cache = cache
    end

    def fetch_prefix_value(prefix, value)
      fetch(key(prefix, value)) do
        yield
      end
    end

    def clear
    end

    protected

    def key(prefix, value)
      "#{prefix}:#{value}"
    end

    def cache
      @cache
    end
  end
end
