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

          transfer_to_enroute(queue_filling) if queue_filling.full?
        rescue => e
          Configurable.notify.call e
        end
      end
    end

    private

    def transfer_to_enroute(queue)
      new_key = queue.transfer_to_enroute

      Configurable.bulk_insert_now.call if !new_key.nil?
    end

    def queue_filling
      @queue_filling ||= Configurable.serialized_queue.call :filling
    end
  end
end
