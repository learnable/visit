module Visit
  class Instrumenter
    def initialize(category)
      @category = category
      @toggle = Configurable.instrumenter_toggle.call(category)
      clear
    end

    def mark(h)
      raise "expected Hash" if !h.instance_of?(Hash)

      mark_with_created_at h if toggle?
    end

    def save_to_log
      if toggle? && (block_given? ? yield : true)
        l = Log.new category: @category, message: to_json
        l.save!
      end
    end

    def clear
      @marks = []

      mark initial
    end

    private

    def toggle?
      @toggle
    end

    def mark_with_created_at(h)
      @marks << hash_with_created_at(h)
    end

    def hash_with_created_at(h)
      h.has_key?(:created_at) ? h : h.merge({created_at: Time.now})
    end

    def initial
      {
        hostname: Socket.gethostname,
        pid: Process.pid
      }
    end

    def to_json
      JSON.generate @marks
    end

    class History
      def initialize(o)
        @marks = marks_from o
      end

      def hostname
        @marks.first["hostname"]
      end

      def pid
        @marks.first["pid"]
      end

      def marks
        @marks.slice(1, @marks.length)
      end

      def timeline
        @marks.map { |h| Time.parse h["created_at"] }
      end

      def to_pretty_str
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
        # o is either a string containing json or a instance of Visit::Log

        JSON.parse(o.instance_of?(Visit::Log) ? o.message : o).map do |mark|
          m = mark.symbolize_keys
          m[:created_at] = Time.parse(m[:created_at]) if m.has_key?(:created_at)
          m
        end
      end
    end
  end
end
