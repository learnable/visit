module Visit
  class Query::CpcCampaign < Query
    def scoped
      super.
        joins(stmt_join_trait("INNER JOIN",      'utm_medium')).
        joins(stmt_join_trait("LEFT OUTER JOIN", 'utm_campaign')).
        where("utm_medium_vtv.v = 'cpc'")
    end
  end
end
