module Visit
  class TraitValue < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    extend HasOptimisticFindOrCreate

    has_many :visit_event_traits, dependent: :destroy

    validates :v, :presence => true, :uniqueness => true

    attr_accessible :v
  end
end
