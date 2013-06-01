module Visit
  class Query::AdwordsLandings < Query
    def initialize(event_ids, relation = Visit::Event.scoped)
      super Query::JoinWithEventIds.new(event_ids, relation).scoped
    end

    def scoped
      super.
        select( %Q{
          visit_events.*,
          utm_medium_vtv.v   AS utm_medium,
          utm_campaign_vtv.v AS utm_campaign,
          utm_term_vtv.v     AS utm_term,
          placement_vtv.v    AS placement
        }).
        joins(stmt_join_trait("LEFT OUTER JOIN", 'utm_medium')).
        joins(stmt_join_trait("LEFT OUTER JOIN", 'utm_campaign')).
        joins(stmt_join_trait("LEFT OUTER JOIN", 'utm_term')).
        joins(stmt_join_trait("LEFT OUTER JOIN", 'placement'))
    end
  end
end
