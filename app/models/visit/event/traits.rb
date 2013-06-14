module Visit
  class Event::Traits < Hash

    def initialize(event)
      path = event.path

      self.tap do |h|
        h.merge! get_match_first(event, path)
        h.merge! get_match_all(event, path).inject(&:merge)
        h.merge! get_user_agent_robot(event)

        h.each do |k,v|
          h[k] = non_nil_v(v)
        end
      end
    end

    private

    def get_match_first(event, path)
       c = Event::MatcherCollection.new Configurable.labels_match_first

       c.match_first_to_h(event.http_method, path)
    end

    def get_match_all(event, path)
       c = Event::MatcherCollection.new Configurable.labels_match_all

       c.match_all_to_a(event.http_method, path)
    end

    def get_user_agent_robot(event)
      {}.tap do |h|
        Configurable.user_agent_robots.each do |name, re|
          if event.user_agent =~ re
            h[:robot] = name
            break
          end
        end
      end
    end

    def non_nil_v(v)
      v.to_s
    end

  end
end
