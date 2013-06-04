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

    def run(a_request_payload_hash)
      cache_setup

      boxes = a_request_payload_hash.map do |rph|
        Box.new RequestPayload.new(rph)
      end

      collect = Collect::SourceValues.new boxes
      collect.transform!
      collect.import!

      collect = Collect::Events.new boxes
      collect.import!  # boxes mutated - now contains :event
      boxes = collect.boxes

      collect = Collect::Sources.new boxes
      collect.transform!
      collect.import!

      create_traits boxes

      cache_restore_original
    end

    private

    def create_traits(boxes)
      collect_traits = Collect::Traits.new boxes
      collect_traits.transform! # boxes mutated - now contains :traits
      boxes = collect_traits.boxes


      collect_trait_values = Collect::TraitValues.new boxes
      collect_trait_values.transform!
      collect_trait_values.import!

      collect_traits.import!
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
