module Visit
  class Query::Robot < Query
    def scoped
      super.
        joins(stmt_join_trait("INNER JOIN", "robot"))
    end
  end
end
