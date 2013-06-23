require 'spec_helper'

describe Visit::SerializedQueue::Redis do

  new_queue = ->(key) do
    Visit::SerializedQueue::Redis.new $redis, key
  end

  it_should_behave_like "a SerializedQueue", new_queue

end


