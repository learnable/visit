module Visit
  class Query::Trait < Query
    def initialize(trait, relation = Event.all)
      @trait = trait
      super relation
    end

    def scoped
      super.
        joins(stmt_join_trait("INNER JOIN", @trait))
    end
  end
end
