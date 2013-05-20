module Visit
  class RequestPayloadHashDecorator
    def initialize(h)
      @h = h
    end

    def to_values
      [].tap do |ret|
        [:url, :user_agent, :referer].each do |k|
          ret << @h[k]
        end

        @h[:cookies].each do |k,v|
          ret << k
          ret << v
        end
      end
    end

    def to_pairs(model)
      [].tap do |ret|
        @h[:cookies].each do |k,v|
          ret << {
            k_id: model.get_id_from_optimistic_find_or_create_by_v(k),
            v_id: model.get_id_from_optimistic_find_or_create_by_v(v)
          }
        end
      end
    end
  end
end
