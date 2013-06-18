require 'spec_helper'

describe Visit::Cache::Memory do
  it_should_behave_like "Cache" do
    let(:cache) { Visit::Cache::Memory.new }
  end
end
