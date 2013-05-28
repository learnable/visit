module Visit
  module Event::HasHttpMethod
    def http_method
      Event::HttpMethod.instance.from_enum http_method_enum
    end

    def http_method=(new_value)
      self.http_method_enum = Event::HttpMethod.instance.to_enum new_value
    end

    private

    class Event::HttpMethod
      include Singleton

      def to_enum(x)
        @forward ||= get_hash
        @forward[x.to_s.downcase.to_sym]
      end

      def from_enum(x)
        @reverse ||= get_hash.invert
        @reverse[x]
      end

      private

      def get_hash
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
    end
  end
end
