module Visit
  class SerializedQueue
    class Redis < SerializedQueue
      def initialize(redis, key_suffix)
        raise "redis must be set" if redis.nil?

        @redis = redis
        @key = key_from_suffix(key_suffix)
      end

      def rpush(data)
        super data

        redis.rpush key, encode(data)
      end

      def lpop
        decode redis.lpop(key)
      end

      def length
        redis.llen key
      end

      def clear
        redis.del key
      end

      def pipelined_rpush_and_return_length(data)
        redis_future_for_length = nil

        redis.pipelined do
          rpush data

          redis_future_for_length = length
        end

        redis_future_for_length.value
      end

      def values
        redis.lrange(key, 0, -1).map { |data| decode(data) }
      end

      def renamenx_to_random_key
        new_key = Helper.random_token

        result = redis.renamenx key, key_from_suffix(new_key)

        result ? new_key : nil
      end

      private

      attr_reader :key
      attr_reader :redis

      def key_from_suffix(suffix)
        "visit:#{Rails.application.class.parent_name.downcase}:#{suffix}"
      end

      def encode(data)
        data.to_json
      end

      def decode(data)
        data.nil? ? nil : JSON.parse(data)
      end
    end
  end
end
