require 'spec_helper'

describe Visit::Cache::Null do
  let(:cache) { Visit::Cache::Null.new }
  let(:key) { Visit::Cache::Key.new("", 111) }

  context "#fetch" do
    it "should evaluate to it's block" do
      tmp = cache.fetch(key) { 111 }
      tmp.should == 111
    end

    it "should never hit cache" do
      hit = 0
      cache.fetch(key) { 111; hit += 1 }
      cache.fetch(key) { 111; hit += 1 }
      hit.should == 2
    end
  end

end
