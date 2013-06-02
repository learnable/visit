module Visit
  module HasOptimisticFindOrCreate
    def get_id_from_optimistic_find_or_create_by_v(v)
      raise "unexpected v.nil?" if v.nil?

      Configurable.cache.fetch(cache_key(v)) do
        optimistic_find_or_create_by_v(v).id
      end
    end

    def get_id_from_find_by_v(v, cache)
      raise "unexpected v.nil?" if v.nil?
      id = nil

      k = cache_key(v)

      if cache.has_key? k
        id = cache.fetch(k)
      else
        row = self.find_by_v(v)

        if !row.nil?
          id = cache.fetch(k) do
            row.id
          end
        end
      end

      id
    end

    def cache_key(v)
      Cache::Key.new(cache_key_prefix, v)
    end

    private

    def optimistic_find_or_create_by_v(v)
      begin
        self.find_or_create_by_v(v)
      rescue ActiveRecord::StatementInvalid => e
        # multiple workers using find_or_create_by can result in a race condition
        # in which case, assume the row exists and return it
        self.find_by_v(v)
      end
    end

    def cache_key_prefix
      @cache_key_prefix ||= "#{self.to_s}.find_by_v.id"
    end
  end
end
