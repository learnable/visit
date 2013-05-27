# a Flow is a sequence of Events, close in time, for a particular user and token
#
module Visit
  class Flow
    def initialize(r)
      raise "unexpected r.nil?" if r.nil?
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

    def token
      @token ||= Event.find(@range.begin).token
    end

    def events
      @events ||= Query::LabelledEvent.new.scoped.
        select("visit_events.*, label_vtv.v as label, capture1_vtv.v as capture1, capture2_vtv.v as capture2").
        where(token: token).where(id: @range).all
    end

    protected

    def present_step(vev)
      "#{vev.label}#{present_capture(vev)}"
    end

    def present_capture(vev)
      if vev.capture1.nil?
        ""
      elsif vev.capture2.nil?
      "(#{vev.capture1})"
      else
      "(#{vev.capture1}/#{vev.capture2})"
      end
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
