module Visit
  class Trait < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    belongs_to :visit_event
    belongs_to :key,   :class_name => "VisitTraitValue", foreign_key: :k_id
    belongs_to :value, :class_name => "VisitTraitValue", foreign_key: :v_id

    validates :k_id, :v_id, :visit_event_id, :presence => true
    validates :k_id, :uniqueness => {
                    :scope => :visit_event_id,
                    :message => "should happen a max of once per visit_event_id" }

  end
end
