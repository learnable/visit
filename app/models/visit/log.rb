module Visit
  class Log < BaseModel
    attr_accessible :category
    attr_accessible :message

    def to_instrumenter_history
      Instrumenter::History.new self
    end
  end
end
