module Visit
  class SourceValue < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    validates :v, :presence => true, :uniqueness => true

    attr_accessible :v
  end
end
