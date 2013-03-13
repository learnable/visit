module Visit
  class Event < ActiveRecord::Base

    self.table_name_prefix = 'visit_'

    has_many :visit_traits, dependent: :destroy
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

    attr_accessible :vid
    attr_accessible :user_id
    attr_accessible :remote_ip

    scope :newer_than_visit_trait, ->(row) { row.nil? ? self : where("id > ?", row.visit_event_id) }

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
      Visit::Event.http_method_from_enum http_method_enum
    end

    def http_method=(new_value)
      self.http_method_enum = Visit::Event.http_method_to_enum new_value
    end

    def url
      Visit::SourceValue.find(url_id).v
    end

    def get_utm path
      str = [ :utm_term, :utm_source, :utm_medium, :utm_content, :utm_campaign ].map do |k|
        h = { http_method: :get, re: Regexp.new("[&|?]#{k.to_s}=(.*?)(&.*|)$"), label: :utm, has_sublabel: true }
        m = Matcher.from_hash h
        m.matches?(http_method, path) ? m.sublabel : ""
      end.join("_")
      str =~ /^_*$/ ? {} : { utm: str }
    end

    def get_gclid path
      h = { http_method: :get, re: /[&|?]gclid=(.*?)(&.*|)$/, label: :gclid, has_sublabel: true }
      m = Matcher.from_hash h
      m.matches?(http_method, path) ?  { gclid: m.sublabel } : {}
    end

    def get_label_sublabel path
       (m = Matcher.first_match(http_method, path)) ? { label: m.label, sublabel: m.sublabel } : {}
    end

    def cols_should_be
      path = Visit::Event.path_from_url(url)
      ret = { }
      ret.merge! get_label_sublabel(path)
      ret.merge! get_utm(path)
      ret.merge! get_gclid(path)
      ret
    end

    private

    def self.h_http_method
      {
        :get     => 1,
        :head    => 2,
        :post    => 3,
        :put     => 4,
        :delete  => 5,
        :trace   => 6,
        :connect => 7,
        :options => 8
      }
    end

    def self.http_method_to_enum x
      @http_method_forward ||= h_http_method

      @http_method_forward[x.to_s.downcase.to_sym]
    end

    def self.http_method_from_enum x
      @http_method_reverse ||= h_http_method.invert

      @http_method_reverse[x]
    end

    def self.path_from_url url
      uri = Addressable::URI.parse(url)
      uri.host ? url.gsub(%r(^.*?#{uri.host}), "") : url # strip scheme and host
    end

  end
end

module Visit
  class Event::Matcher < Struct.new(:http_method, :re, :label, :has_sublabel)
    def self.all
      Visit::Configurable.labels.map { |h| Visit::Event::Matcher.new *h.values_at(*Visit::Event::Matcher.members) }
    end

    def self.from_hash h
      self.new *h.values_at(*Visit::Event::Matcher.members)
    end

    def self.first_match other_http_method, path
      all.detect { |m| m.matches? other_http_method, path }
    end

    def sublabel
      if has_sublabel
        raise "Sublabel not extracted" unless instance_variable_defined?(:@sublabel)
        @sublabel
      end
    end

    def matches? other_http_method, path
      http_method_matches?(other_http_method) && path_matches?(path)
    end

    private

    def http_method_matches? other
      any_http_method? || !other || same_http_method?(other)
    end

    def path_matches? path
      if re =~ path
        @sublabel = $1
        true
      else
        false
      end
    end

    def any_http_method?
      !http_method
    end

    def same_http_method? other
      String(http_method).casecmp(other.to_s) == 0
    end

  end
end
