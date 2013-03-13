module Visit
  class EventView < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    self.primary_key = "id"

    include Visit::StoresIpAddress
    stores_ip_address :remote_ip

    class << self
      # Scopes
      #
      def newer_than_row row
        row.nil? ? self : where("created_at > ?", row.created_at)
      end

      def with_label
        where("label IS NOT NULL")
      end

      def with_distinct_vids_for_user user_id
        select("distinct vid").where(user_id: user_id)
      end

      def with_visit_by_user user_id
        where(vid: Visit::EventView.with_distinct_vids_for_user(user_id))
      end
    end

  end
end
