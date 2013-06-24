require 'visit/serialized_queue/has_instances.rb'

module Visit
  class SerializedQueue
    class Memory < SerializedQueue
      include Visit::SerializedQueue::HasInstances

      def initialize
        @queue = []
      end

      def rpush(data)
        super data
        @queue << data
      end

      def lpop
        @queue.shift
      end

      def length
        @queue.length
      end

      def clear
        @queue = []
      end

      def pipelined_rpush_and_return_length(data)
        rpush data
        length
      end

      def values
        @queue
      end

      def renamenx_to_random_key
        new_key = Helper.random_token

        self.class.clone_to_instance(self, new_key)

        clear

        new_key
      end
    end
  end
end
