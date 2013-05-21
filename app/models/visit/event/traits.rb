module Visit
  class Event::Traits

    def initialize(event)
      @event = event
      @path = Event.path_from_url(event.url)
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
       c = Event::MatcherCollection.new Configurable.labels_match_first

       c.match_first_to_h(@event.http_method, @path)
    end

    def get_match_all
       c = Event::MatcherCollection.new Configurable.labels_match_all

       c.match_all_to_a(@event.http_method, @path)
    end

    def get_user_agent_robot
      {}.tap do |h|
        Configurable.user_agent_robots.each do |name, re|
          if @event.user_agent =~ re
            h[:robot] = name
            break
          end
        end
      end
    end
  end
end
