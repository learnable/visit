module Visit
  class Query::LabelledEvent < Query
    def initialize(a_traits = [], relation = Event.scoped)
      @relation = relation
      @a_traits = a_traits.map(&:to_s)
    end

    def scoped
      relation = @relation.joins(stmt_join_trait("INNER JOIN", 'label'))
      relation = add_joins_for_traits(relation)   if !@a_traits.empty?
      relation = add_selects_for_traits(relation) if !@a_traits.empty?
      relation
    end

    private

    def add_joins_for_traits(relation)
      relation.joins(@a_traits.map {|k| stmt_join_trait("LEFT OUTER JOIN", k) }.join(""))
    end

    def add_selects_for_traits(relation)
      relation.select("visit_events.*, label_vtv.v as label, #{select_string_for_traits}")
    end

    def select_string_for_traits
      @a_traits.map {|k| "#{k}_vtv.v as #{k}" }.join(",")
    end
  end
end
