# a Flow is a sequence of Events, close in time
#
module Visit
  class Flow
    def initialize(events)
      @events = events
    end

    def self.new_from_relation(relation, breakpoint = Breakpoint.new)
      [].tap do |collection|
        breakpoint.each_array_of_events(relation) do |a|
          collection << self.new(a)
        end
      end
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
      @token ||= @events.first.token
    end

    def events
      @events
    end

    def user_id
      ve_with_user_id = @events.select { |ve| !ve.user_id.nil? }

      ve_with_user_id.empty? ? nil : ve_with_user_id.first.user_id
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
