module Visit
  class Event::Matcher < Struct.new(:http_method, :re, :label, :has_sublabel)
    def matches?(other_http_method, path)
      http_method_matches?(other_http_method) && path_matches?(path)
    end

    def result_to_label_h
      has_sublabel ? { label: label, sublabel: sublabel } : { label: label }
    end

    def result_to_value_h
      { label => sublabel }
    end

    private

    def sublabel
      if has_sublabel
        raise "Sublabel not extracted" unless instance_variable_defined?(:@sublabel)
        @sublabel
      end
    end

    def http_method_matches?(other)
      any_http_method? || !other || same_http_method?(other)
    end

    def path_matches?(path)
      if re =~ path
        @sublabel = $1
        ret = true
      else
        ret = false
      end
      # Visit::Manage.log "AMHERE: path_matches?: re: #{re} path: #{path} returns: #{ret}"
      ret
    end

    def any_http_method?
      http_method == :any
    end

    def same_http_method?(other)
      String(http_method).casecmp(other.to_s) == 0
    end

  end
end
