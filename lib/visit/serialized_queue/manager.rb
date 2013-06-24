require 'visit/serialized_string'

module Visit
  class SerializedQueue
    class Manager
      def queue_lengths
        [].tap do |a|
          a.push top_level_lengths

          if queue(:enroute).length > 0
            a.push ({ :enroute => available_lengths })
          end
        end
      end

      def transfer_to_enroute
        queue(:filling).transfer_to_enroute
      end

      private

      def queue(key)
        Configurable.serialized_queue.call key
      end

      def top_level_lengths
        {
          :filling => queue(:filling).length,
          :enroute => queue(:enroute).length 
        }
      end

      def available_lengths
        queue(:enroute).values.map { |a| SerializedString.new(a).decode }.map do |key|
          { key => queue(key).length }
        end 
      end
    end
  end
end
