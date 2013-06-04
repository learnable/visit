module Visit
  class Factory
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
      cache_setup

      boxes = request_payload_hashes.map do |rph|
        Box.new RequestPayload.new(rph)
      end

      # Each of these import! steps populates a table
      # that the next import! needs a foreign key reference for.
      # So the order is important.
      # The collection of boxes is mutated along the way.
      #
      Collect::SourceValues.import! boxes

      Collect::Events.import! boxes

      Collect::Sources.import! boxes

      create_traits boxes

      cache_restore_original
    end

    private

    def create_traits(boxes)
      collect = Collect::Traits.new boxes
      collect.transform! # boxes mutated - now contains :traits

      Collect::TraitValues.import! boxes

      collect.bulk_insert!
    end

    def cache_setup
      if Configurable.cache.instance_of? Visit::Cache::Null
        @original_cache = Configurable.cache
        Configurable.cache = Visit::Cache::Memory.new
      else
        @original_cache = nil
      end
    end

    def cache_restore_original
      if !@original_cache.nil?
        Configurable.cache = @original_cache
        @original_cache = nil
      end
    end
  end

  class Box < Struct.new(:request_payload, :event, :traits)
  end

end
