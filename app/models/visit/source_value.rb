module Visit
  class SourceValue < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    extend HasOptimisticFindOrCreate

    attr_accessible :v
  end
end
