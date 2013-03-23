module Visit
  class Flow::Ranges
    class << self

      # 1. For all visits that can be traced to a particular user
      # 2. Organise the visits into 'ranges'
      #    A 'range' is the begin+end points of a collection of visits close to each other in time.
      #    A range can only have one vid. ie. if the visit cookie got deleted, it's a new range.
      # 3. Return an array of (begin.id..end.id) for each range.
      #
      def for_user(user_id)
        [].tap do |a|
          for_each_range(user_id) do |r|
            a << r
          end
        end
      end

      private

      def for_each_range(user_id)
        previous = nil
        begin_range_id = nil

        Visit::EventView.with_label.traceable_to_user(user_id).find_each do |current|

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
        !previous.nil? && (vid_change?(current, previous) || time_gap?(current, previous))
      end

      def vid_change?(a, b)
        a.vid != b.vid
      end

      def time_gap?(a, b)
        (a.created_at - b.created_at).abs > 2.hours
      end

    end
  end
end
