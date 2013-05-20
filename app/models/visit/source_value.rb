module Visit
  class SourceValue < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    extend HasOptimisticFindOrCreate

    # TODO - replace uniqueness with a sweeper
    # validates :v, :uniqueness => true

    attr_accessible :v
  end
end
