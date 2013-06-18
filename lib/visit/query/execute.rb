module Visit
  class Query::Execute < Query
    def initialize(stmt)
      @stmt = stmt
    end

    def to_a
      ActiveRecord::Base.connection.execute(@stmt).to_a
    end
  end
end
