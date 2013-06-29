module Visit
  class Event::Traits

    def initialize(event)
      @h_fk = {}.tap do |h|
        h[:url] = non_nil_v_ify! get_url(event)

        h[:user_agent] = non_nil_v_ify! get_user_agent(event)
      end
    end

    def to_h
      {}.tap { |ret| @h_fk.keys.each { |fk| ret.merge! @h_fk[fk] } }
    end

    def to_h_fk
      @h_fk
    end

    private

    def get_url(event)
      path = event.path

      {}.tap do |h|
        h.merge! get_match_first(event, path)
        h.merge! get_match_all(event, path).inject(&:merge)
      end
    end

    def get_user_agent(event)
      {}.tap do |h|
        Configurable.user_agent_robots.each do |name, re|
          if event.user_agent =~ re
            h[:robot] = name
            break
          end
        end
      end
    end

    def get_match_first(event, path)
       c = Event::MatcherCollection.new Configurable.labels_match_first

       c.match_first_to_h(event.http_method, path)
    end

    def get_match_all(event, path)
       c = Event::MatcherCollection.new Configurable.labels_match_all

       c.match_all_to_a(event.http_method, path)
    end

    def non_nil_v(v)
      v.to_s
    end

    def non_nil_v_ify!(h)
      h.each { |k,v| h[k] = non_nil_v(v) }
    end
  end
end
