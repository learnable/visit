module Visit
  class Query
    def initialize(relation = Event.scoped)
      @relation = relation
    end

    def scoped
      @relation
    end

    def tokens
      scoped.select("DISTINCT visit_events.token").pluck("visit_events.token")
    end

    protected

    def stmt_join_trait(join_type, key)
      t = table_alias_prefix key

      %Q{
        #{join_type} visit_traits #{t}_vt
          ON visit_events.id = #{t}_vt.visit_event_id
          AND #{t}_vt.k_id = (select id from visit_trait_values where v = '#{key}')

        #{join_type} visit_trait_values #{t}_vtv
          ON #{t}_vtv.id = #{t}_vt.v_id
      }
    end

    def table_alias_prefix(key)
      key
    end
  end
end
