module Visit
  class Manage
    class << self

      def log msg
        Rails.logger.debug "AMHERE: Rails: #{$0}: #{msg}"
        puts "AMHERE: puts: #{$0}: #{msg}"
      end

      def irc_message vid
        s = summary(vid)

        message = "vid: #{vid}, time on site: #{s[:time_on_site_words]}"
        message << ", coupon: #{s[:coupon]}" unless s[:coupon].nil?
        message << ", nav: #{s[:nav]}"
        message
      end

      def destroy_ignored_rows
        a_to_destroy = []
        Visit::Event.find_end do |ve|
          a_to_destroy << ve.id if ve.ignore?
        end

        a_to_destroy.each_slice(1000) do |a|
          Visit::Event.destroy(a)
        end
        a_to_destroy
      end

      def archive_visit_events_batch days=93
        age = days.days.ago.utc
        count = 1
        Visit::Event.select("id").where("created_at < ?", age).find_in_batches do |a_ve|
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
