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

      def delete_visit_traits
        Visit::Trait.delete_all
        Visit::TraitValue.delete_all
      end

      def recreate_visit_traits
        delete_visit_traits
        run :create_visit_traits_batch
      end

      def run *methods
        methods.each do |m|
          self.send m do |activity|
            a = activity.keys.map do |k|
              puts "#{k}: #{activity[k]}"
            end
          end
        end
      end

      def create_visit_traits_batch
        vav_cache = {}

        Visit::Event.newer_than_visit_trait(Visit::Trait.last).find_in_batches do |a_ve|
          activity = {}
          a_insert_values = []

          a_ve.each do |ve|
            create_visit_traits_insert_values ve, a_insert_values, activity, vav_cache
          end

          if !a_insert_values.empty?
            stmt = "INSERT INTO visit_traits (k_id, v_id, visit_event_id, created_at) values" + a_insert_values.join(',')
            ActiveRecord::Base.connection.execute(stmt)
          end

          # batch insert like this is 10x faster than create!
          # but it wouldn't hurt to now do a batch validation of the visit_traits just inserted

          if block_given?
            yield activity
          end
        end
      end

      def create_visit_traits_insert_values ve, a_insert_values, activity, vav_cache = nil
        activity[ve.id] = {}

        ve.cols_should_be.each do |k,v|
          if !v.nil? && !v.empty?
            k_id = visit_trait_value_id k, vav_cache
            v_id = visit_trait_value_id v, vav_cache

            # va = Visit::Trait.create! :k_id => k_id, :v_id => v_id, :visit_event_id => ve.id
            a_insert_values << "(#{k_id}, #{v_id}, #{ve.id}, '#{Time.now}')"
            activity[ve.id][k] = v
          end
        end
      end

      def visit_trait_value_id str, vav_cache
        if vav_cache && vav_cache.has_key?(str)
          ret = vav_cache[str]
        else
          ret = Visit::TraitValue.where(:v => str).first_or_create(:v => str).id
          vav_cache[str] = ret if vav_cache
        end
        ret
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
