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
        h.merge! get_user_agent_robot
      end
    end

    private

    def get_utm
      str = [ :utm_term, :utm_source, :utm_medium, :utm_content, :utm_campaign ].map do |k|
        m = Visit::Event::Matcher.new :get, Regexp.new("[&|?]#{k.to_s}=(.*?)(&.*|)$"), :utm, true
        m.matches?(@ve.http_method, @path) ? m.sublabel : ""
      end.join("_")
      str =~ /^_*$/ ? {} : { utm: str }
    end

    def get_gclid
      m = Visit::Event::Matcher.new :get, /[&|?]gclid=(.*?)(&.*|)$/, :gclid, true
      m.matches?(@ve.http_method, @path) ?  { gclid: m.sublabel } : {}
    end

    def get_label_sublabel
       (m = Visit::Event::Matcher.first_match(@ve.http_method, @path)) ? { label: m.label, sublabel: m.sublabel } : {}
    end

    def get_user_agent_robot
      {}.tap do |h|
        Visit::Configurable.user_agent_robots.each do |str|
          if @ve.user_agent =~ Regexp.new(str, true)
            h[:robot] = str
            break
          end
        end
      end
    end
  end
end
