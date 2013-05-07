module Visit
  class TraitValue < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    has_many :visit_event_traits, dependent: :destroy

    validates :v, :presence => true, :uniqueness => true

    attr_accessible :v

    def self.optimistic_find_or_create_by_v(v)
      begin
        Visit::TraitValue.find_or_create_by_v(v)
      rescue ActiveRecord::StatementInvalid => e
        # multiple workers using find_or_create_by can result in a race condition
        # in which case, assume the row exists and return it
        Visit::TraitValue.find_by_v(v)
      end
    end
  end
end
