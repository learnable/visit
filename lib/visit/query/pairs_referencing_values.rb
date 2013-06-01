module Visit
  class Query::PairsReferencingValues < Query
    def initialize(model_class, ids)
      @model_class = model_class
      @ids = ids
    end

    def scoped
      @model_class.
        where("k_id IN (?) OR v_id IN (?)", @ids, @ids)
    end
  end
end
