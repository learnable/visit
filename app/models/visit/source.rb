module Visit
  class Source < BaseModel
    self.table_name = "visit_sources"

    belongs_to :visit_event, :class_name => "Visit::Event"
    belongs_to :key,         :class_name => "Visit::SourceValue", foreign_key: :k_id
    belongs_to :value,       :class_name => "Visit::SourceValue", foreign_key: :v_id

    validates :k_id, :v_id, :visit_event_id, :presence => true

    def in_use?
      RequestPayload.cookie_filter( { key.v => value.v } ).empty?
    end

  end
end
