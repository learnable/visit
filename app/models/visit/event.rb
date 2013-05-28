require 'addressable/uri'

module Visit
  class Event < ActiveRecord::Base

    self.table_name_prefix = 'visit_'

    has_many :visit_traits,  class_name: "Visit::Trait",  foreign_key: "visit_event_id", dependent: :destroy
    has_many :visit_sources, class_name: "Visit::Source", foreign_key: "visit_event_id", dependent: :destroy

    has_many :visit_trait_keys,   class_name: "::Visit::Trait", :through => :visit_traits, :source => :key,   dependent: :destroy
    has_many :visit_trait_values, class_name: "::Visit::Trait", :through => :visit_traits, :source => :value, dependent: :destroy

    belongs_to :visit_source_values_url,        class_name: "Visit::SourceValue", foreign_key: "url_id"
    belongs_to :visit_source_values_user_agent, class_name: "Visit::SourceValue", foreign_key: "user_agent_id"
    belongs_to :visit_source_values_referer,    class_name: "Visit::SourceValue", foreign_key: "referer_id"

    belongs_to :user

    validates :url_id,        presence: true
    validates :user_agent_id, presence: true
    validates :remote_ip,     presence: true

    include Visit::StoresIpAddress
    stores_ip_address :remote_ip

    attr_accessible :token
    attr_accessible :user_id
    attr_accessible :remote_ip

    include Event::HasCachedAttributes
    include Event::HasHttpMethod

    def self.token_length
      @token_length ||= Visit::Event.columns.select{|c| c.name == 'token' }.first.limit
    end

    def self.path_from_url(url)
      uri = Addressable::URI.parse(url)
      uri.host ? url.gsub(%r(^.*?#{uri.host}), "") : url # strip scheme and host
    end

    def self.ignore?(path)
      ret = nil

      Configurable.ignorable.each do |re|
        ret = path =~ re
        break if ret
      end

      !ret.nil?
    end

    def ignore?
      Event.ignore? Event.path_from_url(url)
    end

  end
end
