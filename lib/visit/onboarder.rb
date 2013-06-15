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
          queue = SerializedQueue::Redis.new

          queue_length = queue.pipelined_append_and_return_length request.to_h

          if queue_length >= Configurable.bulk_insert_batch_size
            Configurable.create.call queue.values

            queue.clear
          end
        rescue => e
          Configurable.notify.call e
        end
      end
    end
  end
end
