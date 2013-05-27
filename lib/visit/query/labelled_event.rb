module Visit
  class Query::LabelledEvent < Query

    def scoped
      @relation.
        joins(stmt)
    end

    protected

    def stmt
      stmt_join_trait("INNER JOIN",      'label') +
      stmt_join_trait("LEFT OUTER JOIN", 'capture1') +
      stmt_join_trait("LEFT OUTER JOIN", 'capture2')
    end

  end
end
