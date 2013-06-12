module Visit
  class Onboarder
    def self.ignorable?(path)
      ret = nil

      Configurable.ignorable.each do |re|
        ret = path =~ re
        break if ret
      end

      !ret.nil?
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
        rescue Exception => e
          Configurable.notify.call e
        end
      end
    end
  end
end
