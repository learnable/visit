module Visit
  class Query::LabelledEvent < Query

    def initialize(a_traits = [], relation = Event.scoped)
      @relation = relation
      @a_traits = a_traits
    end

    def scoped
      @relation.
        joins(stmt)
    end

    protected

    def stmt
      stmt_join_trait("INNER JOIN", 'label') + "\n" + stmts_for_traits
    end

    def stmts_for_traits
      @a_traits.map do |k|
        stmt_join_trait("LEFT OUTER JOIN", k.to_s)
      end.join("")
    end

  end
end
