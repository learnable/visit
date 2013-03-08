module Visit
  class Flow
    def initialize start_id, finish_id
      @start_id  = start_id
      @finish_id = finish_id
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
        Visit::EventView.with_label.where("id BETWEEN ? AND ?", @start_id, @finish_id).find_each do |vev|
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
