module Visit
  class SerializedQueue
    class Manager
      def queue_lengths
        [].tap do |a|
          a.push top_level_lengths

          if queue(:available).length > 0
            a.push ({ :available => available_lengths })
          end
        end
      end

      def make_available
        queue(:filling).make_available
      end

      private

      def queue(key)
        Configurable.serialized_queue.call key
      end

      def top_level_lengths
        {
          :filling => queue(:filling).length,
          :available => queue(:available).length 
        }
      end

      def available_lengths
        queue(:available).values.map do |key|
          { key => queue(key).length }
        end 
      end
    end
  end
end
