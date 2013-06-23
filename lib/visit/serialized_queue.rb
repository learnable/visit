module Visit
  class SerializedQueue
    def full?
      length >= Configurable.bulk_insert_batch_size
    end

    def make_available
      new_key = renamenx_to_random_key

      if !new_key.nil?
        Configurable.serialized_queue.call(:available).rpush new_key
      end

      new_key
    end
  end
end

