module Visit
  class Onboarder
    def self.ignorable?(path)
      Configurable.ignorable.any? { |re| path =~ re }
    end

    def accept_unless_ignorable(rails_request_context)
      raise "unexpected argument" unless rails_request_context.instance_of?(RailsRequestContext)

      unless rails_request_context.ignorable?
        begin
          rails_request_context.must_insert = true

          queue_filling.pipelined_rpush_and_return_length rails_request_context.to_h

          make_available(queue_filling) if queue_filling.full?

          # TODO: remove references to queue_legacy once flippa has migrated
          make_available(queue_legacy) if (queue_legacy.length > 0)
        rescue => e
          Configurable.notify.call e
        end
      end
    end

    private

    def make_available(queue)
      new_key = queue.renamenx_to_random_key

      if !new_key.nil?
        Configurable.serialized_queue.call(:available).rpush new_key
        Configurable.bulk_insert_now.call
      end
    end

    def queue_filling
      @queue_filling ||= Configurable.serialized_queue.call :filling
    end

    def queue_legacy
      @queue_legacy ||= Configurable.serialized_queue.call "request_payload_hashes"
    end
  end
end
