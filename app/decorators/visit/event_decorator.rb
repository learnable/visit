module Visit
  class EventDecorator
    # a cheap and cheerful decorator with no external dependencies
    def initialize(event)
      @event = event
    end

    def user_agent_family
      require 'user_agent_parser'

      UserAgentParser.parse(@event.user_agent).family
    end
  end
end


