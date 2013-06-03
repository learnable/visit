module Visit
  class Outage < Range
    def self.new_from_relation(relation = Event.scoped, gap = 2.minutes)
      previous = nil

      [].tap do |a|
        relation.find_each do |current|
          if !previous.nil? && (current.created_at - previous.created_at > gap)
            a.push self.new previous, current
          end
          previous = current
        end
      end
    end

    def start_time_in_words
      helpers.time_ago_in_words(first.created_at)
    end

    def duration_in_words
      helpers.distance_of_time_in_words(first.created_at, last.created_at)
    end

    private

    def helpers
      ActionController::Base.helpers
    end

  end
end
