module Visit
  class VisitAttribute < ActiveRecord::Base
    self.table_name = "visit_attributes"

    belongs_to :visit_event
    belongs_to :key,   :class_name => "VisitAttributeValue", foreign_key: :k_id
    belongs_to :value, :class_name => "VisitAttributeValue", foreign_key: :v_id

    validates :k_id, :v_id, :visit_event_id, :presence => true
    validates :k_id, :uniqueness => {
                    :scope => :visit_event_id,
                    :message => "should happen a max of once per visit_event_id" }

  end
end
