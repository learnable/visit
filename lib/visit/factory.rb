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
          create_traits a_event.map { |event| { event: event } }
        end
    end

    def run(a_request_payload_hash)
      cache_setup

      a_request_payload_hash.each { |rph| rph.symbolize_keys! }

      collect = Collect::SourceValues.new a_request_payload_hash
      collect.transform!
      collect.import!

      collect = Collect::Events.new a_request_payload_hash
      collect.import!
      a_request_payload_hash = collect.collection # contains :event

      collect = Collect::Sources.new a_request_payload_hash
      collect.transform!
      collect.import!

      create_traits(a_request_payload_hash)

      cache_restore_original
    end

    private

    def create_traits(a_event)
      collect_traits = Collect::Traits.new a_event
      collect_traits.transform!
      a_event = collect_traits.collection # contains :traits

      collect_trait_values = Collect::TraitValues.new a_event
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

end
