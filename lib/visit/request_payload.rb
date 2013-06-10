require 'visit/has_ignorable_path'

module Visit
  class RequestPayload < Struct.new(:http_method, :url, :token, :user_id, :user_agent, :referer, :remote_ip, :cookies, :created_at)

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

    def to_values
      [].tap do |ret|
        [:url, :user_agent, :referer].each do |k|
          ret << self[k]
        end

        self[:cookies].each do |k,v|
          ret << k
          ret << v
        end
      end
    end

    def to_pairs
      [].tap do |ret|
        self[:cookies].each do |k,v|
          ret << {
            k_id: SourceValue.get_id_from_optimistic_find_or_create_by_v(k),
            v_id: SourceValue.get_id_from_optimistic_find_or_create_by_v(v)
          }
        end
      end
    end
  end
end
