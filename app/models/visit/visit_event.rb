module Visit
  class VisitEvent < ActiveRecord::Base

    has_many :visit_attributes, dependent: :destroy

    belongs_to :user

    include StoresIpAddress
    stores_ip_address :remote_ip

    attr_accessible :http_method
    attr_accessible :url
    attr_accessible :vid
    attr_accessible :user_id
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

      def with_membership_status status
        joins(:user => :membership)
          .where("memberships.status = ?", status)
      end
    end

    def self.ignore? path
      ret = nil
      [
        /^\/system/,
        /^\/webmatrix/,
        /^\/geckoboard/,
        /^\/visit\/tag\.gif/,
        /^\/books\/.*\/images\//,
        /^\/books\/.*\/figures\//,
        /^\/books\/.*\.css\b/,
        /.\js($|\/|\?)/
      ].each do |re|
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
        cookie_membership_coupon_token.nil? ? {} : { coupon: cookie_membership_coupon_token }
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
      def self.all
        [
          {                     re: /^\/(\?.*|)$/,                                                  label: :home                     },
          {                     re: /^\/sitepoint\b/,                                               label: :channel_sitepoint        },
          {                     re: /^\/membership\/sitepoint\b/,                                   label: :membership_sitepoint     },
          {                     re: /^\/membership\?course_id/,                                     label: :membership_course        },
          {                     re: /^\/membership$/,                                               label: :membership_public        },
          { http_method: :post, re: /\/contact/,                                                    label: :contact                  },
          { http_method: :post, re: /\/sign-in\/lost-password/,                                     label: :lost_password            },
          { http_method: :get,  re: /\/sign-in/,                                                    label: :sign_in_prompt           },
          { http_method: :post, re: /\/sign-in/,                                                    label: :sign_in                  },
          { http_method: :get,  re: /\/sign-up/,                                                    label: :sign_up_prompt           },
          { http_method: :post, re: /\/sign-up/,                                                    label: :sign_up                  },
          {                     re: /\/sign-out/,                                                   label: :sign_out                 },
          {                     re: /^\/membership\/orders\/\w*\/success/,                          label: :success                  },
          { http_method: :post, re: /^\/membership\/orders\/\w*\/payments$/,                        label: :payment_attempt          },
          { http_method: :get,  re: /^\/membership\/orders\/\w*$/,                                  label: :place_mship_order_prompt },
          {                     re: /^\/offer\?/,                                                   label: :offer_mship              },
          {                     re: /^\/orders\/new\?course_id/,                                    label: :place_course_order       },
          {                     re: /^\/learn\/topic.*q=(.*?)(|\&.*)$/,                             label: :search,                  has_sublabel: true },
          {                     re: /^\/search.*\?q=(.*?)(|\&.*)$/,                                 label: :search,                  has_sublabel: true },
          {                     re: /\/preview\b/,                                                  label: :preview                  },
          {                     re: /^\/learn\/\w*/,                                                label: :topic                    },
          {                     re: /^\/courses\/search.*\?q=(.*?)(|\&.*)$/,                        label: :search,                  has_sublabel: true },
          { http_method: :post, re: /^\/courses\/.*-(\d+)\/enrollment/,                             label: :enroll,                  has_sublabel: true },
          {                     re: /^\/courses\/.*-(\d+)/,                                         label: :course,                  has_sublabel: true },
          {                     re: /^\/categories/,                                                label: :browse_courses           },
          {                     re: /^\/courses\b/,                                                 label: :browse_courses           },
          {                     re: /^\/books\b(|\/)$/,                                             label: :browse_books             },
          {                     re: /^\/books\/(\w+)\/online/,                                      label: :book,                    has_sublabel: true },
          {                     re: /^\/membership\/(monthly|annual)/,                              label: :payment_page,            has_sublabel: true },
          {                     re: /^\/teach\b/,                                                   label: :teach                    },
          { http_method: :post, re: /^\/social(|\/)$/,                                              label: :social_new_conversation  },
          { http_method: :post, re: /^\/social\/(\d+)\/post$/,                                      label: :social_new_reply         },
          {                     re: /^\/social\b(|\/)$/,                                            label: :social                   },
          {                     re: /\/pageviews.*action=payment_processing.*payment_status=(\w*)/, label: :payment_status,          has_sublabel: true },
          {                     re: /^\/legal-stuff\/terms-of-service/,                             label: :terms_of_service         }
        ].map { |h| Matcher.new *h.values_at(*Matcher.members) }
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
