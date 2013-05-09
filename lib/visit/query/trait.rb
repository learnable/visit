module Visit
  class Query
    class Trait < Query
      def initialize(trait, relation = Visit::Event.scoped)
        @trait = trait
        super relation
      end

      protected

      def stmt
        stmt_join_trait("INNER JOIN", @trait)
      end
    end
  end
end
