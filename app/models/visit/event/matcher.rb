module Visit
  class Event::Matcher < Struct.new(:http_method, :re, :label, :has_sublabel)
    def matches?(other_http_method, path)
      http_method_matches?(other_http_method) && path_matches?(path)
    end

    def result_to_label_h
      (@matchdata.size > 1) ? { label: label, sublabel: sublabel } : { label: label }
    end

    def result_to_value_h
      { label => sublabel }
    end

    private

    def sublabel
      @matchdata[1]
    end

    def http_method_matches?(other)
      any_http_method? || !other || same_http_method?(other)
    end

    def path_matches?(path)
      @matchdata = re.match(path)
      # Visit::Manage.log "AMHERE: path_matches?: re: #{re} path: #{path} matchdata: #{@matchdata}"
      ! @matchdata.nil?
    end

    def any_http_method?
      http_method == :any
    end

    def same_http_method?(other)
      String(http_method).casecmp(other.to_s) == 0
    end

  end
end
