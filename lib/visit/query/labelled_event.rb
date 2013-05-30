module Visit
  class Query::LabelledEvent < Query

    def initialize(a_traits = [], relation = Event.scoped)
      @relation = relation
      @a_traits = a_traits.map(&:to_s)
    end

    def scoped
      relation = @relation.joins(stmt)
      relation = add_joins_for_traits(relation)
      relation = add_selects_for_traits(relation)
      relation
    end

    protected

    def stmt
      stmt_join_trait("INNER JOIN", 'label')
    end

    def add_joins_for_traits(relation)
      @a_traits.empty? ?
        relation :
        relation.joins(@a_traits.map {|k| stmt_join_trait("LEFT OUTER JOIN", k) }.join(""))
    end

    def add_selects_for_traits(relation)
      @a_traits.empty? ?
        relation :
        relation.select("visit_events.*, label_vtv.v as label, #{select_string_for_traits}")
    end

    def select_string_for_traits
      @a_traits.map {|k| "#{k}_vtv.v as #{k}" }.join(",")
    end

  end
end
