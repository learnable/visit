module Visit
  class VisitEventView < ActiveRecord::Base
    self.table_name = "visit_event_views"

    set_primary_key "id" # postgres adapter needs this, otherwise find_each breaks # AMHERE - put in 'things I learned'

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
    end

  end
end
