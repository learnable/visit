module Visit
  module Event::HasCachedAttributes
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
      key = Cache::Key.new "SourceValue.find", id

      Configurable.cache.fetch(key) do
        yield
      end
    end

    def nil_or_value(vsv)
      vsv.nil? ? nil : vsv.v
    end
  end
end
