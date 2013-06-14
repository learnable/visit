require 'visit/has_ignorable_path'

module Visit
  class RequestPayload < Struct.new(:http_method, :url, :token, :user_id, :user_agent, :referer, :remote_ip, :cookies, :created_at)

    def self.cookie_filter(cookies)
      cookies.select do |k,v|
        Configurable.cookies_match.any? { |re| k =~ re }
      end
    end

    include Visit::HasIgnorablePath

    def initialize(h = {})
      members.each do |k|
        k_to_s = k.to_s

        if h.has_key?(k)
          self[k] = h[k]
        elsif h.has_key?(k_to_s)
          self[k] = h[k_to_s]
        end
      end
    end

    def to_h
      members.inject({}) do |acc, k|
        acc.merge(k => send(k))
      end
    end

    def to_values
      [].tap do |ret|
        [:url, :user_agent, :referer].each do |k|
          ret << non_nil_v(self[k])
        end

        filtered_cookies.each do |k,v|
          ret << k
          ret << non_nil_v(v)
        end
      end
    end

    def to_pairs
      [].tap do |ret|
        filtered_cookies.each do |k,v|
          ret << {
            k_id: SourceValue.get_id_from_optimistic_find_or_create_by_v(k),
            v_id: SourceValue.get_id_from_optimistic_find_or_create_by_v(non_nil_v(v))
          }
        end
      end
    end

    private

    def filtered_cookies
      self.class.cookie_filter(self[:cookies])
    end

    def non_nil_v(v)
      v.to_s
    end
  end
end
