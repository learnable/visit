require 'addressable/uri'

module Visit
  # A model representing a HTTP request. The various HTTP headers are stored as references into
  # the visit_source_values table. For example, the User Agent for a particular request may be
  # "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/125.2 (KHTML, like Gecko) Safari/125.8"
  # This string is stored at the 'v' attribute in a visit_source_values row, and the user_agent_id attribute of
  # this model stores the id of that row.
  class Event < ActiveRecord::Base

    self.table_name_prefix = 'visit_'

    has_many :visit_traits, class_name: "Visit::Trait", foreign_key: "visit_event_id", dependent: :destroy
    has_many :visit_sources, class_name: "Visit::Source", foreign_key: "visit_event_id", dependent: :destroy
    has_many :visit_source_values

    belongs_to :user

    validates :url_id,
      presence: true

    validates :user_agent_id,
      presence: true

    validates :remote_ip,
      presence: true

    include Visit::StoresIpAddress
    stores_ip_address :remote_ip

    # vid is the 'visit id', or can be thought of as the 'visitor id'.
    # It aims to be a basic identification method, linking together requests by
    # the same user.
    # The vid is persisted across requests via a cookie.
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
      self.url_id = Visit::SourceValue.find_or_create_by_v(s).id
    end

    def user_agent
      Visit::SourceValue.find(user_agent_id).v
    end

    def user_agent=(s)
      self.user_agent_id = Visit::SourceValue.find_or_create_by_v(s).id
    end

  end
end
