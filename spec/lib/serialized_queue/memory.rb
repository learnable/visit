require 'spec_helper'

describe Visit::SerializedQueue::Memory do

  it_should_behave_like "a SerializedQueue" do
    let(:queue) { Visit::SerializedQueue::Memory.new }
  end

  it "#instance(arg) returns a singleton" do
    q1 = Visit::SerializedQueue::Memory.instance(:a)
    q2 = Visit::SerializedQueue::Memory.instance(:a)

    q1.object_id.should == q2.object_id
  end

end


