module Visit
  class SerializedQueue
    def full?
      length >= Configurable.bulk_insert_batch_size
    end

    def rpush(data)
      if !(data.instance_of?(Hash) || data.instance_of?(Array))
        raise "only key/value pairs or arrays can be converted to json"
      end
    end

    def transfer_to_enroute
      new_key = renamenx_to_random_key

      if !new_key.nil?
        Configurable.serialized_queue.call(:enroute).rpush new_key
      end

      new_key
    end
  end
end

