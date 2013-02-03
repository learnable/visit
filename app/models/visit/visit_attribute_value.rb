module Visit
  class VisitAttributeValue < ActiveRecord::Base
    self.table_name = "visit_attribute_values"

    has_many :visit_event_attributes, dependent: :destroy

    validates :v, :presence => true, :uniqueness => true

    attr_accessible :v
  end
end
