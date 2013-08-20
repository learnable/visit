module Visit
  class Log < BaseModel
    attr_accessible :category
    attr_accessible :message

    self.table_name = "visit_logs"

    def to_instrumenter_history
      Instrumenter::History.new self
    end
  end
end
