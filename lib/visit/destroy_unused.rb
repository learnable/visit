module Visit
  class DestroyUnused
    class << self

      def rows!
        events!
        sources!
        source_values!
      end

      def events!
        Event.includes(:visit_source_values_url).find_in_batches do |events|
          ids  = events.select { |event| event.ignorable? }.map(&:id)

          Source.delete_all(visit_event_id: ids)
          Event.delete ids

          yield ids if block_given?
        end
      end

      def sources!
        Source.includes([:key, :value]).find_in_batches do |sources|
          ids = sources.select { |source| source.in_use? }.map(&:id)

          Source.delete ids

          yield ids if block_given?
        end
      end

      def source_values!
        # TODO
      end

    end
  end
end
