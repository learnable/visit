module Visit
  class Log < BaseModel
    self.table_name = "visit_logs"

    def to_instrumenter_history
      Instrumenter::History.new self
    end
  end
end
