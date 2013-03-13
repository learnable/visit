module Visit
  class Flow
    def initialize r
      @range = r
    end

    def self.new_from_ranges ranges
      [].tap do |a|
        ranges.each do |r|
          a << self.new(r)
        end
      end.reverse
    end

    def has_label? label
      !select_label(label).empty?
    end

    def steps
      events.select do |vev|
        vev.label !~ /.*_prompt$/
      end.map do |vev|
        present_step vev
      end.join(" -> ")
    end

    def start_time_in_words
      helpers.distance_of_time_in_words(Time.now, events.first.created_at)
    end

    def time_on_site_in_words
      first = events.first
      last = events.last

      last.nil? ? nil : helpers.distance_of_time_in_words(last.created_at, first.created_at)
    end

    def vid
      events.first.vid
    end

    def events
      @events ||= [].tap do |a|
        vid = Visit::Event.find(@range.begin).vid
        Visit::EventView.
          where(vid: vid).
          with_label.
          where("id BETWEEN ? AND ?", @range.begin, @range.end).
          find_each do |vev|
            a.push vev
        end
      end
    end

    protected

    def present_step vev
      vev.sublabel.nil? ? vev.label : "#{vev.label}(#{vev.sublabel})"
    end

    def select_label label
      label = label.to_s
      events.select { |vev| vev.label == label }
    end

    private

    def helpers
      ActionController::Base.helpers
    end

  end
end

module Visit
  class Flow
    class Ranges
      class << self

        def for_user user_id
          [].tap do |a|
            for_each_range(user_id) do |r|
              a << r
            end
          end
        end

        private

        def for_each_range user_id
          vev_prev = nil
          begin_range = nil

          Visit::EventView.with_label.with_visit_by_user(user_id).find_each do |vev|
            begin_range = vev.id if begin_range.nil?

            if !vev_prev.nil? && range_change?(vev, vev_prev)
              yield (begin_range..vev_prev.id)
              begin_range = vev.id
            end

            vev_prev = vev
          end

          yield(begin_range..vev_prev.id) unless begin_range.nil?
        end

        def range_change? vev, vev_prev
          vid_change?(vev, vev_prev) || time_gap?(vev, vev_prev)
        end

        def vid_change? vev1, vev2
          vev1.vid != vev2.vid
        end

        def time_gap? vev1, vev2
          (vev1.created_at - vev2.created_at).abs > 2.hours
        end

      end
    end
  end
end
