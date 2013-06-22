module Visit
  class SerializedQueue
    class Redis
      def initialize(redis, key_suffix = "request_payload_hashes")
        raise "redis must be set" if redis.nil?

        @redis = redis
        @key ||= key_from_suffix(key_suffix)
      end

      def rpush(data)
        redis.rpush key, data.to_yaml
      end

      def lpop
        YAML.load redis.lpop(key)
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

      def pipelined_lpop_and_clear(max)
        redis_future_values = []

        redis.pipelined do
          for count in (1..max) do
            redis_future_values.push redis.lpop(key)
          end
        end

        clear

        redis_future_values.map do |future|
          future.value.nil? ? nil : YAML.load(future.value)
        end.select do |value|
          !value.nil?
        end
      end

      private

      attr_reader :key

      def key_from_suffix(suffix)
        "visit:#{Rails.application.class.parent_name}:#{suffix}"
      end

      def redis
        @redis
      end
    end
  end
end
