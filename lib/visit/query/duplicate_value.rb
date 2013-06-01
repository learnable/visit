module Visit
  class Query::DuplicateValue < Query
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
