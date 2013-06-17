require 'spec_helper'

describe Visit::SerializedQueue::Memory do

  it_should_behave_like "a SerializedQueue" do
    let(:queue) { Visit::SerializedQueue::Memory.new }
  end

end


