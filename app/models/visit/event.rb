require 'addressable/uri'
require 'visit/has_ignorable'
require 'visit/has_path'

module Visit
  class Event < BaseModel
    self.table_name = "visit_events"

    has_many :visit_traits,  class_name: "Visit::Trait",  foreign_key: "visit_event_id", dependent: :destroy
    has_many :visit_sources, class_name: "Visit::Source", foreign_key: "visit_event_id", dependent: :destroy

    belongs_to :visit_source_values_url,        class_name: "Visit::SourceValue", foreign_key: "url_id"
    belongs_to :visit_source_values_user_agent, class_name: "Visit::SourceValue", foreign_key: "user_agent_id"
    belongs_to :visit_source_values_referer,    class_name: "Visit::SourceValue", foreign_key: "referer_id"

    belongs_to :user

    validates :url_id,    presence: true
    validates :remote_ip, presence: true

    include Visit::StoresIpAddress
    stores_ip_address :remote_ip

    include Event::HasCachedAttributes
    include Event::HasHttpMethod
    include Visit::HasIgnorable
    include Visit::HasPath

    TOKEN_LENGTH = 16

    def to_traits
      Traits.new self
    end

    def source_value_fk_ids
      uk = UniqueKeys.new
      uk.push [ url_id, user_agent_id, referer_id ]
      uk.keys
    end

    def source_value_ids
      uk = UniqueKeys.new
      uk.push [ url_id, user_agent_id, referer_id ]
      visit_sources.each { |source| uk.push [ source.k_id, source.v_id ] }
      uk.keys
    end
  end
end
