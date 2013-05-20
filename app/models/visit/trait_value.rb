module Visit
  class TraitValue < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    extend HasOptimisticFindOrCreate

    attr_accessible :v
  end
end
