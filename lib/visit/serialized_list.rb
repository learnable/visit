module Visit
  class SerializedList

    def initialize(key_suffix = "request_payload_hashes")
      @key = "visit:#{Rails.application.class.parent_name}:#{key_suffix}"
    end

    def append(data)
      redis.rpush(@key, data.to_yaml)
    end

    def values
      redis.lrange(@key, 0, -1).map { |data| YAML.load(data) }
    end

    def length
      redis.llen(@key)
    end

    def clear
      redis.del(@key)
    end

    def pipelined_append_and_return_length data
      redis_future_for_length = nil

      redis.pipelined do
        append data

        redis_future_for_length = length
      end

      redis_future_for_length.value
    end

    private

    def redis
      if Visit::Configurable.redis.nil?
        raise "Visit::Connfigurable.redis is not set, please configure it"
      else
        Visit::Configurable.redis
      end
    end
  end
end
