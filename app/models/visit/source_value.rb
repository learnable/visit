module Visit
  class SourceValue < BaseModel
    extend HasOptimisticFindOrCreate

    attr_accessible :v
  end
end
