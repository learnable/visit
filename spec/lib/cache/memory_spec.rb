require 'spec_helper'

describe Visit::Cache::Memory do
  let(:cache) { Visit::Cache::Memory.new }

  context "#fetch" do
    it "should evaluate to it's block" do
      tmp = cache.fetch(222) { 111 }
      tmp.should == 111
    end

    context "should hit cache" do
      it "on the first fetch of a key but not the second" do
        hit = ""
        cache.fetch(222) { 111; hit += "a" }
        cache.fetch(222) { 111; hit += "b" }
        hit.should == "a"
      end

      it "on the first fetch of a key after #clear" do
        hit = ""
        cache.fetch(222) { 111; hit += "a" }
        cache.fetch(222) { 111; hit += "b" }
        cache.clear
        cache.fetch(222) { 111; hit += "c" }
        hit.should == "ac"
      end
    end
  end
end
