require 'visit/has_temporary_cache'
require 'visit/serialized_string'

module Visit
  class Factory
    include Visit::HasTemporaryCache

    def self.delete_traits
      Visit::Trait.delete_all
      Visit::TraitValue.delete_all
    end

    def recreate_traits
      self.class.instrumenter.category = :factory_recreate_traits
      self.class.instrumenter.clear
      self.class.instrumenter.mark start: :recreate_traits

      Configurable.cache.clear

      Factory.delete_traits

      self.class.instrumenter.mark delete_traits_done: nil

      temporary_cache_setup

      count = 0
      batch_size = 1000
      Visit::Event.includes(includes).find_in_batches(batch_size: batch_size) do |a_event|
        create_traits a_event.map { |event| Box.new(nil, event, nil) }
        count += batch_size
        self.class.instrumenter.mark create_traits_progress: count
      end

      temporary_cache_teardown
      self.class.instrumenter.mark finish: :recreate_traits
      self.class.instrumenter.save_to_log
    end

    def run
      self.class.instrumenter.category = :factory_run
      self.class.instrumenter.clear
      self.class.instrumenter.mark start: :run

      request_payloads = get_request_payloads

      # Helper.log "AMHERE: Factory.run: count: #{request_payloads.count} request_payloads: #{request_payloads}"

      temporary_cache_setup

      boxes = request_payloads.map { |rp| Box.new rp }

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

      self.class.instrumenter.mark finish: :run
      self.class.instrumenter.save_to_log
    end

    private

    def self.instrumenter
      @instrumenter ||= Instrumenter.new
    end

    def create_traits(boxes)
      collect = Collect::Traits.new boxes
      collect.transform!

      Collect::TraitValues.import! boxes

      collect.bulk_insert!
    end

    def get_request_payloads
      key = SerializedString.new(serialized_queue_for(:enroute).lpop).decode

      raise "Factory#run didn't expect the :enroute queue to be empty" if key.empty?

      request_payload_hashes = serialized_queue_for(key).values

      raise "expected queue to have values" if request_payload_hashes.empty?

      request_payloads = request_payload_hashes.map do |rph|
        RequestPayload.new rph
      end.select do |request_payload|
        !request_payload.ignorable?
      end

      self.class.instrumenter.mark \
        after_get_request_payloads: key,
        request_payloads_count: request_payloads.count,
        request_payload_hashes_count: request_payload_hashes.count

      request_payloads
    end

    def serialized_queue_for(key)
      Configurable.serialized_queue.call(key)
    end

    def includes
      [
        :visit_source_values_url,
        :visit_source_values_user_agent,
        :visit_source_values_referer
      ]
    end
  end

  class Box < Struct.new(:request_payload, :event, :traits)
  end

end
