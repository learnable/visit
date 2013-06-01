module Visit
  class Query::JoinWithEventIds < Query
    def initialize(event_ids, relation = Event.scoped)
      super relation
      @event_ids = event_ids
    end

    def scoped
      super.
        joins %Q{
          INNER JOIN
            (SELECT * FROM visit_events WHERE id IN (#{@event_ids.join(',')})) visit_event_ids
            ON visit_event_ids.id = visit_events.id
        }
    end
  end
end
