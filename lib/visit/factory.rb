module Visit
  class Factory
    class << self
      def delete_traits
        Trait.delete_all
        TraitValue.delete_all
      end

      def recreate_traits
        Configurable.cache.clear

        delete_traits

        factory = Factory.new

        Visit::Event.
          includes([:visit_source_values_url, :visit_source_values_user_agent, :visit_source_values_referer]).
          find_in_batches do |a_event|
            factory.create_traits a_event.map { |event| { event: event } }
          end
      end

      def run(a_request_payload_hash)
        # Manage.log "AMHERE: Visit::Factory.run: a_request_payload_hash: #{a_request_payload_hash.to_yaml}"

        a_request_payload_hash.each { |rph| rph.symbolize_keys! }

        collect = Collect::SourceValues.new Visit::SourceValue, a_request_payload_hash
        collect.transform!
        collect.import!

        collect = Collect::Events.new Visit::Event, a_request_payload_hash
        collect.import!
        a_request_payload_hash = collect.collection # contains :event

        collect = Collect::Sources.new Visit::Source, a_request_payload_hash
        collect.transform!
        collect.import!

        create_traits(a_request_payload_hash)
      end

      def create_traits(a_event)
        collect_traits = Collect::Traits.new Visit::Trait, a_event
        collect_traits.transform!
        a_event = collect_traits.collection # contains :traits

        collect_trait_values = Collect::TraitValues.new Visit::TraitValue, a_event
        collect_trait_values.transform!
        collect_trait_values.import!

        collect_traits.import!
      end
    end
  end
end
