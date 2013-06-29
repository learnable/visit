module Visit
  class Event::Traits
    def initialize(event)
      @event = event

      @h_fk = {}.tap do |h|
        h[:url]        = fetch(:url)        { non_nil_v! get_url        }
        h[:user_agent] = fetch(:user_agent) { non_nil_v! get_user_agent }
      end
    end

    def to_h
      {}.tap { |ret| @h_fk.keys.each { |fk| ret.merge! @h_fk[fk] } }
    end

    private

    attr_reader :event
    attr_reader :h_fk

    def get_url
      {}.tap do |h|
        h.merge! get_match_first
        h.merge! get_match_all.inject(&:merge)
      end
    end

    def get_user_agent
      {}.tap do |h|
        Configurable.user_agent_robots.each do |name, re|
          if event.user_agent =~ re
            h[:robot] = name
            break
          end
        end
      end
    end

    def get_match_first
       c = Event::MatcherCollection.new Configurable.labels_match_first

       c.match_first_to_h(event.http_method, path)
    end

    def get_match_all
       c = Event::MatcherCollection.new Configurable.labels_match_all

       c.match_all_to_a(event.http_method, path)
    end

    def non_nil_v!(h)
      h.each { |k,v| h[k] = v.to_s }
    end

    def path
      @path ||= event.path
    end

    def fetch(fk)
      key = cache_key(fk)

      Configurable.cache.fetch(key, Cache.short_term) do
        yield
      end
    end

    def cache_key(fk)
      id = event.send "#{fk}_id"

      Cache::Key.new "#{self.class.to_s}:#{fk}", id
    end
  end
end
