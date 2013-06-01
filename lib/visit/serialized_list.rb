module Visit
  class SerializedList

    def initialize(key_suffix)
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

    private

    def redis
      Visit::Configurable.redis
    end
  end
end
