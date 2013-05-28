module Visit
  class Flow::Ranges
    def initialize(relation)
      @relation = relation
    end

    # 1. For all visits associated with this relation
    # 2. Organise the visits into 'ranges'
    #    A Range is the begin+end points of a collection of visits close to each other in time.
    #    All points in a Range have the same token. ie. if the visit cookie got deleted, it's a new Range.
    # 3. Return an array of (begin.id..end.id) for each Range.
    #
    def get
      [].tap do |collection|
        for_each_range do |r|
          collection << r
        end
      end
    end

    private

    def for_each_range
      previous = nil
      begin_range_id = nil

      @relation.find_each do |current|
        if range_breakpoint?(current, previous)
          yield (begin_range_id..previous.id)
          begin_range_id = current.id
        end

        previous = current
        begin_range_id = current.id if begin_range_id.nil?
      end

      yield (begin_range_id..previous.id) unless begin_range_id.nil?
    end

    def range_breakpoint?(current, previous)
      !previous.nil? && (token_change?(current, previous) || time_gap?(current, previous))
    end

    def token_change?(a, b)
      a.token != b.token
    end

    def time_gap?(a, b)
      (a.created_at - b.created_at).abs > 2.hours
    end

  end
end
