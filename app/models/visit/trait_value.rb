module Visit
  class TraitValue < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    extend HasOptimisticFindOrCreate

    has_many :visit_event_traits, dependent: :destroy

    # TODO - replace uniqueness with a sweeper
    # validates :v, :presence => true, :uniqueness => true
    validates :v, :presence => true

    attr_accessible :v
  end
end
