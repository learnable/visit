module Visit
  class Manage
    class << self

      def irc_message vid
        s = summary(vid)

        message = "vid: #{vid}, time on site: #{s[:time_on_site_words]}"
        message << ", coupon: #{s[:coupon]}" unless s[:coupon].nil?
        message << ", nav: #{s[:nav]}"
        message
      end

      def summary vid
        nav = []
        first_visit, last_visit = nil, nil
        is_success = false
        coupon = nil
        vid = vid.to_s

        Visit::VisitEventView.where("vid = ? AND label IS NOT NULL", vid).find_each do |vev|
          if first_visit.nil?
            first_visit = vev
          else
            last_visit = vev
          end

          nav << vev.label if vev.label !~ /.*_prompt$/

          if vev.label == 'success'
            is_success = true
            coupon = vev.coupon
          end
        end

        {
          :coupon => coupon,
          :is_success => is_success,
          :nav => nav.join(summary_separator),
          :time_on_site_words => (last_visit.nil? ? nil : helpers.distance_of_time_in_words(last_visit.created_at, first_visit.created_at)),
          :vid => vid
        }
      end

      def destroy_ignored_rows
        a_to_destroy = []
        Visit::VisitEvent.find_end do |ve|
          a_to_destroy << ve.id if ve.ignore?
        end

        a_to_destroy.each_slice(1000) do |a|
          Visit::VisitEvent.destroy(a)
        end
        a_to_destroy
      end

      def vids_for_utm utm
        h_success = { }

        Visit::VisitEventView.vids_for(utm, 'success').find_each do |row|
          h_success[row.vid] = true
        end

        a_nosuccess = [ ]

        Visit::VisitEventView.vids_for(utm).find_each do |row|
          a_nosuccess << row.vid unless h_success.has_key?(row.vid)
        end

        { :success => h_success.keys, :nosuccess => a_nosuccess }
      end

      def delete_visit_attributes
        Visit::VisitAttribute.delete_all
        Visit::VisitAttributeValue.delete_all
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

      def create_visit_attributes_batch
        vav_cache = {}

        Visit::VisitEvent.newer_than_visit_attribute(Visit::VisitAttribute.last).find_in_batches do |a_ve|
          activity = {}
          a_insert_values = []

          a_ve.each do |ve|
            create_visit_attributes_insert_values ve, a_insert_values, activity, vav_cache
          end

          if !a_insert_values.empty?
            stmt = "INSERT INTO visit_attributes (k_id, v_id, visit_event_id, created_at) values" + a_insert_values.join(',')
            ActiveRecord::Base.connection.execute(stmt)
          end

          # batch insert like this is 10x faster than create!
          # but it wouldn't hurt to now do a batch validation of the visit_attributes just inserted

          if block_given?
            yield activity
          end
        end
      end

      def create_visit_attributes_insert_values ve, a_insert_values, activity, vav_cache = nil
        activity[ve.id] = {}

        ve.cols_should_be.each do |k,v|
          if !v.nil? && !v.empty?
            k_id = visit_attribute_value_id k, vav_cache
            v_id = visit_attribute_value_id v, vav_cache

            # va = Visit::VisitAttribute.create! :k_id => k_id, :v_id => v_id, :visit_event_id => ve.id
            a_insert_values << "(#{k_id}, #{v_id}, #{ve.id}, '#{Time.now}')"
            activity[ve.id][k] = v
          end
        end
      end

      def visit_attribute_value_id str, vav_cache
        if vav_cache && vav_cache.has_key?(str)
          ret = vav_cache[str]
        else
          ret = Visit::VisitAttributeValue.where(:v => str).first_or_create(:v => str).id
          vav_cache[str] = ret if vav_cache
        end
        ret
      end

      def archive_visit_events_batch days=93
        age = days.days.ago.utc
        count = 1
        Visit::VisitEvent.select("id").where("created_at < ?", age).find_in_batches do |a_ve|
          a_id = a_ve.map { |ve| ve.id }
          ids = a_id.join(',')
          activity = {}

          stmts = [
            "INSERT INTO visit_event_archives SELECT * from visit_events WHERE id IN (#{ids})",
            "DELETE FROM visit_attributes WHERE visit_event_id in (#{ids})",
            "DELETE FROM visit_events WHERE id in (#{ids})",
            %{
              DELETE FROM visit_attribute_values
              WHERE id NOT IN (SELECT DISTINCT k_id FROM visit_attributes)
              AND   id NOT IN (SELECT DISTINCT v_id FROM visit_attributes)
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

      private

      def helpers
        ActionController::Base.helpers
      end

      def summary_separator
        " -> "
      end
    end
  end
end
