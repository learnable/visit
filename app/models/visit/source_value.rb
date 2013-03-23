module Visit
  class SourceValue < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    validates :v, :presence => true, :uniqueness => true

    attr_accessible :v

    def self.optimistic_find_or_create_by_v(v)
      begin
        Visit::SourceValue.find_or_create_by_v(v)
      rescue ActiveRecord::StatementInvalid => e
        # multiple workers using find_or_create_by can result in a race condition
        # in which case, assume the row exists and return it
        Visit::SourceValue.find_by_v(v)
      end
    end
  end
end
