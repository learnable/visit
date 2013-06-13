require 'visit/has_temporary_cache'

module Visit
  class Factory

    include Visit::HasTemporaryCache

    def self.delete_traits
      Visit::Trait.delete_all
      Visit::TraitValue.delete_all
    end

    def recreate_traits
      Configurable.cache.clear

      Factory.delete_traits

      Visit::Event.
        includes([:visit_source_values_url, :visit_source_values_user_agent, :visit_source_values_referer]).
        find_in_batches do |a_event|
          create_traits a_event.map { |event| Box.new(nil, event, nil) }
        end
    end

    def run(request_payload_hashes)
      temporary_cache_setup

      boxes = request_payload_hashes.map do |rph|
        Box.new RequestPayload.new(rph)
      end

      # Each import! step populates a table
      # that the next import! step references as a foreign key.
      #
      # The boxes collection is mutated:
      # - by Collect::Events, which sets box.event
      # - by Collect::Traits, which sets box.traits
      #

      Collect::SourceValues.import! boxes

      Collect::Events.import! boxes

      Collect::Sources.import! boxes

      create_traits boxes

      temporary_cache_teardown
    end

    private

    def create_traits(boxes)
      collect = Collect::Traits.new boxes
      collect.transform!

      Collect::TraitValues.import! boxes

      collect.bulk_insert!
    end

  end

  class Box < Struct.new(:request_payload, :event, :traits)
  end

end
