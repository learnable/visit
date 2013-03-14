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
      !events_with_label(label).empty?
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

    def events_with_label label
      label = label.to_s
      events.select { |vev| vev.label == label }
    end

    private

    def helpers
      ActionController::Base.helpers
    end

  end
end