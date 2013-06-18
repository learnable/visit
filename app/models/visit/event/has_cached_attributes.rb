module Visit
  module Event::HasCachedAttributes
    extend ActiveSupport::Concern

    module ClassMethods
      def cache_key_for_id(id)
        Cache::Key.new "Event.find", id
      end
    end

    def url
      fetch_from_cache(url_id) do
        nil_or_value visit_source_values_url
      end
    end

    def user_agent
      fetch_from_cache(user_agent_id) do
        nil_or_value visit_source_values_user_agent
      end
    end

    def referer
      fetch_from_cache(referer_id) do
        nil_or_value visit_source_values_referer
      end
    end

    private

    def fetch_from_cache(id)
      Configurable.cache.fetch(self.class.cache_key_for_id(id)) do
        yield
      end
    end

    def nil_or_value(vsv)
      vsv.nil? ? nil : vsv.v
    end
  end
end
