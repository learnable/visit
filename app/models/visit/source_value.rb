module Visit
  class SourceValue < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    extend HasOptimisticFindOrCreate

    validates :v, :presence => true, :uniqueness => true

    attr_accessible :v
  end
end
