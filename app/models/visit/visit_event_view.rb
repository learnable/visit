module Visit
  class VisitEventView < ActiveRecord::Base

    include StoresIpAddress
    stores_ip_address :remote_ip

    class << self
      # Scopes
      #
      def visit_ids_for(utm, label = nil)
        select = select("DISTINCT(visit_event_views.visit_id)").where(:utm => utm)
        label ?
          select.joins("INNER JOIN visit_event_views vev on vev.visit_id = visit_event_views.visit_id").where("vev.label = ?", label) :
          select
      end

      def newer_than_row row
        row.nil? ? self : where("created_at > ?", row.created_at)
      end
    end

  end
end
