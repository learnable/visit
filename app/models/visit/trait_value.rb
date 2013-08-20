module Visit
  class TraitValue < BaseModel
    extend HasOptimisticFindOrCreate

    self.table_name = "visit_trait_values"

    attr_accessible :v
  end
end
