module Visit
  class SourceValue < BaseModel
    extend HasOptimisticFindOrCreate

    self.table_name = "visit_source_values"

    attr_accessible :v
  end
end
