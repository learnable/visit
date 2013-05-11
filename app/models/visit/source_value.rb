module Visit
  class SourceValue < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    extend HasOptimisticFindOrCreate

    # TODO - replace uniqueness with a sweeper
    # validates :v, :presence => true, :uniqueness => true
    validates :v, :presence => true

    attr_accessible :v
  end
end
