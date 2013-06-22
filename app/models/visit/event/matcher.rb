module Visit
  class Event::Matcher < Struct.new(:http_method, :re, :label)
    def matches?(other_http_method, path)
      http_method_matches?(other_http_method) && path_matches?(path)
    end

    def matchdata_to_label_h
      { label: label }.tap do |h|
        (1..(@matchdata.size-1)).each { |i| h["capture#{i}".to_sym] = @matchdata[i] }
      end
    end

    def matchdata_to_value_h
      { label => @matchdata[1] }
    end

    private

    def http_method_matches?(other)
      any_http_method? || !other || same_http_method?(other)
    end

    def path_matches?(path)
      @matchdata = re.match path
      # Helper.log "AMHERE: path_matches?: re: #{re} path: #{path} matchdata: #{@matchdata}"
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
