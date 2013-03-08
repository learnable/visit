module Visit
  class Flow
    def initialize vid
      @vid = vid.to_s
    end

    def has_label? label
      !select_label(label).empty?
    end

    def steps
      events_with_labels.select do |vev|
        vev.label !~ /.*_prompt$/
      end.map do |vev|
          vev.sublabel.nil? ? vev.label : "#{vev.label}(#{vev.sublabel})"
      end.join(" -> ")
    end

    def time_on_site_in_words 
      first = events_with_labels.first
      last = events_with_labels.last

      last.nil? ? nil : helpers.distance_of_time_in_words(last.created_at, first.created_at)
    end

    protected

    def select_label label
      label = label.to_s
      events_with_labels.select { |vev| vev.label == label }
    end

    def events_with_labels
      @events_with_labels ||= [].tap do |a|
        Visit::EventView.where("vid = ? AND label IS NOT NULL", @vid).find_each do |vev|
          a.push vev
        end
      end
    end

    private

    def helpers
      ActionController::Base.helpers
    end

  end
end
