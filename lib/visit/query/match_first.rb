module Visit
  class Query::MatchFirst < Query
    def initialize(relation = Event.scoped)
      super relation
    end

    def scoped
      super.
        joins(stmt_join_source_value("INNER JOIN", "url")).
        joins(stmt_join_source_value("LEFT OUTER JOIN", "referer")).
        joins(stmt_join_source_value("LEFT OUTER JOIN", "user_agent")).
        joins(stmt_join_trait("LEFT OUTER JOIN", "label")).
        joins(stmt_join_trait("LEFT OUTER JOIN", "capture1")).
        joins(stmt_join_trait("LEFT OUTER JOIN", "capture2"))
    end
  end
end
