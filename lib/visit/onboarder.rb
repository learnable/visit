module Visit
  class Onboarder
    def self.ignorable?(path)
      Configurable.ignorable.any?{|re| path =~ re}
    end

    def self.accept_unless_ignorable(request)
      # request is either RailsRequestContext or RequestPayload
      #
      unless request.ignorable?
        begin
          list = SerializedList.new("request_payload_hashes")

          list_length = list.pipelined_append_and_return_length request.to_h

          if list_length >= Configurable.bulk_insert_batch_size
            Configurable.create.call list.values

            list.clear
          end
        rescue
          Configurable.notify.call $!
        end
      end
    end
  end
end
