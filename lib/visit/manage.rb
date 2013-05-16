module Visit
  class Manage
    class << self

      def log(msg)
        Rails.logger.debug "AMHERE: Rails: #{$0}: #{msg}"
        puts "AMHERE: puts: #{$0}: #{msg}"
      end

      def destroy_ignorable
        Event.includes(:visit_source_values_url).find_in_batches do |a_ve|
          a_to_be_destroyed = a_ve.map { |ve| ve.ignore? ? ve.id : nil }.select{ |id| !id.nil? }

          Event.destroy a_to_be_destroyed

          yield a_to_be_destroyed if block_given?
        end
      end

      def archive_visit_events(days=93)
        age = days.days.ago.utc
        count = 1
        Event.select("id").where("created_at < ?", age).find_in_batches do |a_ve|
          a_id = a_ve.map { |ve| ve.id }
          ids = a_id.join(',')
          activity = {}

          stmts = [
            "INSERT INTO visit_event_archives SELECT * from visit_events WHERE id IN (#{ids})",
            "DELETE FROM visit_traits WHERE visit_event_id in (#{ids})",
            "DELETE FROM visit_events WHERE id in (#{ids})",
            %{
              DELETE FROM visit_trait_values
              WHERE id NOT IN (SELECT DISTINCT k_id FROM visit_traits)
              AND   id NOT IN (SELECT DISTINCT v_id FROM visit_traits)
            }
          ]

          ActiveRecord::Base.transaction do
            stmts.each do |stmt|
              ActiveRecord::Base.connection.execute stmt
            end
          end

          activity[count] = "archived visit_event ids: #{ids}"
          count += 1

          if block_given?
            yield activity
          end
        end
      end

    end
  end
end
