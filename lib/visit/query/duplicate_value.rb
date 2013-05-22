module Visit
  class Query
    class DuplicateValue < Query
      def initialize(model_class)
        @model_class = model_class
      end

      def scoped
        @model_class.
          select('v, count(v)').
          group('v HAVING count(v) > 1')
      end
    end
  end
end
