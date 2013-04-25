module Visit
  class Event::Traits

    def initialize(ve)
      @ve = ve
      @path = Visit::Event.path_from_url(ve.url)
    end

    def to_h
      { }.tap do |h|
        h.merge! get_match_first
        h.merge! get_match_all.inject(&:merge)
        h.merge! get_user_agent_robot
      end
    end

    private

    def get_match_first
       c = Event::MatcherCollection.new Visit::Configurable.labels_match_first

       c.match_first_to_h(@ve.http_method, @path)
    end

    def get_match_all
       c = Event::MatcherCollection.new Visit::Configurable.labels_match_all

       c.match_all_to_a(@ve.http_method, @path)
    end

    def get_user_agent_robot
      {}.tap do |h|
        Visit::Configurable.user_agent_robots.each do |re|
          if @ve.user_agent =~ re
            h[:robot] = re.to_s
            break
          end
        end
      end
    end
  end
end
