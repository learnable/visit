module Visit
  class VisitAttributeValue < ActiveRecord::Base
    has_many :visit_event_attributes, dependent: :destroy

    validates :v, :presence => true, :uniqueness => true
  end
end
