module Visit
  class Source < ActiveRecord::Base
    self.table_name_prefix = 'visit_'

    belongs_to :visit_event, :class_name => "Visit::Event"
    belongs_to :key,   :class_name => "Visit::SourceValue", foreign_key: :k_id
    belongs_to :value, :class_name => "Visit::SourceValue", foreign_key: :v_id

    validates :k_id, :v_id, :visit_event_id, :presence => true
  end
end
