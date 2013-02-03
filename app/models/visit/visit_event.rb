module Visit
  class VisitEvent < ActiveRecord::Base

    # I found that enclosing modules were being included in table as per the 
    # 'class' scheme here (not module):
    # http://apidock.com/rails/ActiveRecord/Base/table_name/class
    # that's why table name is set explicitly here:
    #
    self.table_name = "visit_events"

    has_many :visit_attributes, dependent: :destroy

    belongs_to :user

    include Visit::StoresIpAddress
    stores_ip_address :remote_ip

    attr_accessible :http_method
    attr_accessible :url
    attr_accessible :vid
    attr_accessible :user_id
    attr_accessible :coupon
    attr_accessible :user_agent
    attr_accessible :remote_ip

    def ignore?
      VisitEvent.ignore? VisitEvent.path_from_url(url)
    end

    class << self
      # Scopes
      #
      def newer_than_visit_attribute row
        row.nil? ? self : where("id > ?", row.visit_event_id)
      end
    end

    def self.ignorable
      [
        /.\js($|\/|\?)/
      ]
    end

    def self.ignore? path
      ret = nil

      ignorable.each do |re|
        ret = path =~ re
        break if ret
      end

      !ret.nil?
    end

    def self.path_from_url url
      uri = Addressable::URI.parse(url)
      uri.host ? url.gsub(%r(^.*?#{uri.host}), "") : url # strip scheme and host
    end

    def self.join_attributes col
      %{
        LEFT OUTER JOIN visit_attributes #{col}_va
        ON visit_events.id = #{col}_va.visit_event_id AND #{col}_va.k_id = (select id from visit_attribute_values where v = '#{col}')
        LEFT OUTER JOIN visit_attribute_values #{col}_vav
        ON #{col}_vav.id = #{col}_va.v_id
      }
    end

    def path_from_url
      VisitEvent.path_from_url url
    end

    def get_utm path
      str = [ :utm_source, :utm_term, :utm_medium, :utm_content, :utm_campaign ].map do |k|
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

    def get_coupon path
      h = { http_method: :get, re: /[&|?]mc=(.*?)(&.*|)$/, label: :coupon, has_sublabel: true }
      m = Matcher.from_hash h
      if m.matches?(http_method, path)
        { coupon: m.sublabel }
      else
        coupon.nil? ? {} : { coupon: coupon }
      end
    end

    def get_label_sublabel path
       (m = Matcher.first_match(http_method, path)) ? { label: m.label, sublabel: m.sublabel } : {}
    end

    def cols_should_be
      path = path_from_url
      ret = { }
      ret.merge! get_label_sublabel(path)
      ret.merge! get_utm(path)
      ret.merge! get_coupon(path)
      ret.merge! get_gclid(path)
      ret
    end

    class Matcher < Struct.new(:http_method, :re, :label, :has_sublabel)
      def self.labels
        [ ]
      end

      def self.all
        labels.map { |h| Matcher.new *h.values_at(*Matcher.members) }
      end

      def self.from_hash h
        self.new *h.values_at(*Matcher.members)
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
        String(http_method).casecmp(other) == 0
      end

    end
  end
end
