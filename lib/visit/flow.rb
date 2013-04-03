# a Flow is a sequence of Events, close in time, for a particular user and vid
#
module Visit
  class Flow
    def initialize(r)
      @range = r
    end

    def self.new_from_ranges(ranges)
      [].tap do |a|
        ranges.each do |r|
          a << self.new(r)
        end
      end.reverse
    end

    def has_label?(label)
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
      @vid ||= Visit::Event.find(@range.begin).vid
    end

    def events
      @events ||= Visit::LabelledEventQuery.new.scoped.where(vid: vid).where(id: @range).all
    end

    protected

    def present_step(vev)
      vev.sublabel.nil? ? vev.label : "#{vev.label}(#{vev.sublabel})"
    end

    def events_with_label(label)
      label = label.to_s
      events.select { |vev| vev.label == label }
    end

    private

    def helpers
      ActionController::Base.helpers
    end

  end
end
