module Visit
  class AttributeValue < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    has_many :visit_event_attributes, dependent: :destroy

    validates :v, :presence => true, :uniqueness => true

    attr_accessible :v
  end
end
