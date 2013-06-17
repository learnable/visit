module Visit
  class SerializedQueue
    class Redis

      def initialize(key_suffix = "request_payload_hashes")
        @key = "visit:#{Rails.application.class.parent_name}:#{key_suffix}"
      end

      def rpush(data)
        redis.rpush(@key, data.to_yaml)
      end

      def lpop
        YAML.load(redis.lpop(@key))
      end

      def length
        redis.llen(@key)
      end

      def clear
        redis.del(@key)
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
            redis_future_values.push redis.lpop(@key)
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

      def redis
        if Visit::Configurable.redis.nil?
          raise "Visit::Connfigurable.redis is not set, please configure it"
        else
          Visit::Configurable.redis
        end
      end
    end
  end
end
