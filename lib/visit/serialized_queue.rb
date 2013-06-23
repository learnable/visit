module Visit
  class SerializedQueue
    def full?
      length > Configurable.bulk_insert_batch_size
    end
  end
end

