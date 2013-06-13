module Visit
  class Manage
    class << self

      def log(msg)
        Rails.logger.debug "AMHERE: Rails: #{$0}: #{msg}"
        puts "AMHERE: puts: #{$0}: #{msg}"
      end

      def destroy_ignorable
        Event.includes(:visit_source_values_url).find_in_batches do |events|
          ids = events.select { |event| event.ignorable? }.map(&:id)

          Event.destroy ids

          yield ids if block_given?
        end
      end

      def destroy_sources_if_not_used
        Source.includes([:key, :value]).find_in_batches do |sources|
          ids = sources.select { |source| source.in_use? }.map(&:id)

          Source.destroy ids

          yield ids if block_given?
        end
      end

    end
  end
end
