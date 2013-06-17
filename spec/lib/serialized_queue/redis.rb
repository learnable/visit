require 'spec_helper'

describe Visit::SerializedQueue::Redis do

  it_should_behave_like "a SerializedQueue" do
    let(:queue) { Visit::SerializedQueue::Redis.new('test_serialized_queue') }
  end

end


