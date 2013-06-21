module Visit
  class Instrumenter
    def initialize(category)
      @category = category
      clear
    end

    def mark(h)
      raise "expected Hash" if !h.instance_of?(Hash)

      mark_with_created_at h
    end

    def save_to_log
      if (block_given? ? yield : true)
        l = Log.new category: @category, message: to_json
        l.save!
      end
    end

    def clear
      @marks = []

      mark initial
    end

    private

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
  end
end
