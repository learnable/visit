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
      def initialize(str)
        @marks = JSON.parse str
      end

      def hostname
        @marks.first["hostname"]
      end

      def pid
        @marks.first["pid"]
      end

      def keys
        @marks.slice(1, @marks.length).map { |h| h.first.first }
      end

      def timeline
        @marks.map { |h| Time.parse h["created_at"] }
      end
    end
  end
end
