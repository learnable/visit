module Visit
  class Query::EventsReferencingValues < Query
    def initialize(ids, relation = Event.scoped)
      super relation
      @ids = ids
    end

    def scoped
      @relation.
        where("url_id IN (?) OR user_agent_id IN (?) OR referer_id IN (?)", @ids, @ids, @ids)
    end
  end
end
