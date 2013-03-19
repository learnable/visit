module Visit
  class Event < ActiveRecord::Base

    self.table_name_prefix = 'visit_'

    has_many :visit_traits, class_name: "Visit::Trait", foreign_key: "visit_event_id", dependent: :destroy
    has_many :visit_sources, class_name: "Visit::Source", foreign_key: "visit_event_id", dependent: :destroy
    has_many :visit_source_values

    has_one :url, class_name: "Visit::SourceValue", foreign_key: "url_id"

    belongs_to :user

    validates :url_id,
      presence: true

    validates :user_agent_id,
      presence: true

    validates :remote_ip,
      presence: true

    include Visit::StoresIpAddress
    stores_ip_address :remote_ip

    attr_accessible :vid
    attr_accessible :user_id
    attr_accessible :remote_ip

    ## Scopes
    #
    def self.newer_than_visit_trait row
      row.nil? ? self : where("id > ?", row.visit_event_id)
    end

    def self.path_from_url url
      uri = Addressable::URI.parse(url)
      uri.host ? url.gsub(%r(^.*?#{uri.host}), "") : url # strip scheme and host
    end

    def self.ignore? path
      ret = nil

      Visit::Configurable.ignorable.each do |re|
        ret = path =~ re
        break if ret
      end

      !ret.nil?
    end

    def ignore?
      Visit::Event.ignore? Visit::Event.path_from_url(url)
    end

    def http_method
      Visit::Event::HttpMethod.instance.from_enum http_method_enum
    end

    def http_method=(new_value)
      self.http_method_enum = Visit::Event::HttpMethod.instance.to_enum new_value
    end

    def url
      Visit::SourceValue.find(url_id).v
    end

    def url=(s)
      url = SourceValue.find_or_initialize_by_v(s)
    end

  end
end
