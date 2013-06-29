module Visit
  class UniqueKeys
    def initialize
      @h = {}
    end

    def push(a)
      a.each { |k| @h[k] = 0 unless k.nil? }
    end

    def keys
      @h.keys
    end
  end
end
