module Visit
  class Onboarder
    def self.ignorable?(path)
      Configurable.ignorable.any? { |re| path =~ re }
    end

    def self.accept_unless_ignorable(request)
      # request is either RailsRequestContext or RequestPayload
      #
      unless request.ignorable?
        begin
          queue = Configurable.serialized_queue.call "request_payload_hashes"

          queue_length = queue.pipelined_rpush_and_return_length request.to_h

          if queue_length >= Configurable.bulk_insert_batch_size
            values = queue.pipelined_lpop_and_clear(Configurable.bulk_insert_batch_size)

            Configurable.create.call values
          end
        rescue => e
          Configurable.notify.call e
        end
      end
    end
  end
end
