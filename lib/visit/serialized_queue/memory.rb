module Visit
  class SerializedQueue
    class Memory

      def initialize
        @queue = []
      end

      def rpush(data)
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
        rpush(data)
        length
      end

      def pipelined_lpop_and_clear(max)
        [].tap do |a|
          for count in (1..max) do
            a << lpop
          end

          clear
        end
      end

    end
  end
end
