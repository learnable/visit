module Visit
  class Manage
    class << self

      def log(msg)
        Rails.logger.debug "AMHERE: Rails: #{$0}: #{msg}"
        puts "AMHERE: puts: #{$0}: #{msg}"
      end

      def destroy_ignorable
        Event.includes(:visit_source_values_url).find_in_batches do |events|
          a_to_be_destroyed = events.map { |ve| ve.ignorable? ? ve.id : nil }.select{ |id| !id.nil? }

          Event.destroy a_to_be_destroyed

          yield a_to_be_destroyed if block_given?
        end
      end

    end
  end
end
