module Visit
  class Query::LabelledEvent < Query

    def scoped
      @relation.
        select("visit_events.*, label_vtv.v as label, capture1_vtv.v as capture1, capture2_vtv.v as capture2").
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
