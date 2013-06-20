module Visit
  class TraitValue < BaseModel
    extend HasOptimisticFindOrCreate

    attr_accessible :v
  end
end
