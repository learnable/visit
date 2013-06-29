module Visit
  class Instrumenter
    class History
      def initialize(o)
        @marks = marks_from o
      end

      attr_reader :marks

      def hostname
        marks.first[:hostname]
      end

      def pid
        marks.first[:pid]
      end

      def timeline
        marks.map { |h| h[:created_at] }
      end

      def timegaps
        prev_created_at = nil

        h = {}.tap do |h|
          marks.each do |m|
            k = m.keys.first
            h[k] = [] if h[k].nil?
            h[k] << (prev_created_at.nil? ? 0 : (m[:created_at] - prev_created_at))
            prev_created_at = m[:created_at]
          end
        end

        h.each do |k,v|
          h[k] = v.inject { |sum, n| sum + n }
        end

        {
          total: h.inject(0) { |sum,x| sum + x.last },
          breakdown: h
        }
      end

      def to_s
        lines = []

        marks.map do |mark|
          lines << mark[:created_at]
          mark.keys.select { |k| k != :created_at }.each do |k|
            lines << "  #{k}: #{mark[k]}"
          end
        end

        lines.join("\n")
      end

      private

      def marks_from(o)
        # o is either:
        # - a string containing json
        # - an instance of Visit::Log
        # - an array

        if o.instance_of? Array
          o
        else
          JSON.parse(o.instance_of?(Visit::Log) ? o.message : o).map do |mark|
            m = mark.symbolize_keys
            m[:created_at] = Time.parse(m[:created_at]) if m.has_key?(:created_at)
            m
          end
        end
      end
    end
  end
end
