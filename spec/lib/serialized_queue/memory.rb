require 'spec_helper'

describe Visit::SerializedQueue::Memory do

  new_queue = ->(key) do
    Visit::SerializedQueue::Memory.instances(key)
  end

  it_should_behave_like "a SerializedQueue", new_queue

  it "#instances(arg) returns a singleton" do
    q1 = Visit::SerializedQueue::Memory.instances(:a)
    q2 = Visit::SerializedQueue::Memory.instances(:a)

    q1.object_id.should == q2.object_id
  end

end


