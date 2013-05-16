module Visit
  class Event::MatcherCollection
    def initialize(a)
      @matchers = a.map { |a| Event::Matcher.new *a }
    end

    def match_first_to_h(other_http_method, path)
      m = @matchers.detect { |m| m.matches? other_http_method, path }
      m ? m.matchdata_to_label_h : {}
    end

    def match_all_to_a(other_http_method, path)
      [{}].tap do |a|
        @matchers.each do |m|
          a << m.matchdata_to_value_h if m.matches?(other_http_method, path)
        end
      end
    end
  end
end
