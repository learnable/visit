module Visit
  class Flow::Breakpoint
    # this class knows chops up an Event relation,
    # yielding a sequence of Arrays containing Events

    def each_array_of_events(relation)
      a = []

      relation.find_each do |current|
        if breakpoint?(current, a.last)
          yield a
          a = [ ]
        end

        a << current
      end

      yield a unless a.empty?
    end

    protected

    def breakpoint?(current, previous)
      !previous.nil? &&
        (token_change?(current, previous) ||
         user_change?(current, previous) ||
         time_gap?(current, previous))
    end

    def token_change?(a, b)
      a.token != b.token
    end

    def user_change?(a, b)
      a.user_id != b.user_id
    end

    def time_gap?(a, b)
      (a.created_at - b.created_at).abs > time_away
    end

    def time_away
      2.hours
    end

  end
end
