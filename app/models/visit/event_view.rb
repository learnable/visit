module Visit
  class EventView < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    self.primary_key = "id"

    include Visit::StoresIpAddress
    stores_ip_address :remote_ip

    class << self
      # Scopes
      #
      def vids_for(utm, label = nil)
        select = select("DISTINCT(visit_event_views.vid)").where(:utm => utm)
        label ?
          select.joins("INNER JOIN visit_event_views vev on vev.vid = visit_event_views.vid").where("vev.label = ?", label) :
          select
      end

      def newer_than_row row
        row.nil? ? self : where("created_at > ?", row.created_at)
      end

      def with_label
        where("label IS NOT NULL")
      end

      def with_labels_for_user user_id
        with_label.where(user_id: user_id)
      end
    end

    def self.flow_starts_for_user user_id
      last_vev = nil
      [].tap do |a|
        Visit::EventView.with_labels_for_user(user_id).find_each do |vev|
          if last_vev.nil? || last_vev.vid != vev.vid || (vev.created_at - last_vev.created_at > 2.hours)
            a.push vev
          end
          last_vev = vev
        end
      end
    end

  end
end
