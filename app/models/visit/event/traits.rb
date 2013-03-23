module Visit
  class Event::Traits

    def initialize(ve)
      @ve = ve
      @path = Visit::Event.path_from_url(ve.url)
    end

    def to_h
      { }.tap do |h|
        h.merge! get_label_sublabel
        h.merge! get_utm
        h.merge! get_gclid
      end
    end

    private

    def get_utm
      str = [ :utm_term, :utm_source, :utm_medium, :utm_content, :utm_campaign ].map do |k|
        h = { http_method: :get, re: Regexp.new("[&|?]#{k.to_s}=(.*?)(&.*|)$"), label: :utm, has_sublabel: true }
        m = Visit::Event::Matcher.from_hash h
        m.matches?(@ve.http_method, @path) ? m.sublabel : ""
      end.join("_")
      str =~ /^_*$/ ? {} : { utm: str }
    end

    def get_gclid
      h = { http_method: :get, re: /[&|?]gclid=(.*?)(&.*|)$/, label: :gclid, has_sublabel: true }
      m = Visit::Event::Matcher.from_hash h
      m.matches?(@ve.http_method, @path) ?  { gclid: m.sublabel } : {}
    end

    def get_label_sublabel
       (m = Visit::Event::Matcher.first_match(@ve.http_method, @path)) ? { label: m.label, sublabel: m.sublabel } : {}
    end
  end
end
