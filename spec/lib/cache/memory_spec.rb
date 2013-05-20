require 'spec_helper'

describe Visit::Cache::Memory do
  let(:cache) { Visit::Cache::Memory.new }
  let(:key) { Visit::Cache::Key.new("", 222) }

  context "#fetch" do
    it "should evaluate to it's block" do
      tmp = cache.fetch(key) { 111 }
      tmp.should == 111
    end

    context "should hit cache" do
      it "on the first fetch of a key but not the second" do
        hit = ""
        cache.fetch(key) { 111; hit += "a" }
        cache.fetch(key) { 111; hit += "b" }
        hit.should == "a"
      end

      it "on the first fetch of a key after #clear" do
        hit = ""
        cache.fetch(key) { 111; hit += "a" }
        cache.fetch(key) { 111; hit += "b" }
        cache.clear
        cache.fetch(key) { 111; hit += "c" }
        hit.should == "ac"
      end
    end
  end
  
  context "#has_key?" do
    it "should return false when key not present" do
      cache.has_key?(key).should be_false
    end
    it "should return true when key present" do
      cache.fetch(key) { 111 }
      cache.has_key?(key).should be_true
    end
    it "should have no side effects" do
      cache.fetch(key) { 111 }

      hit = false
      result = cache.fetch(key) { 111; hit = true }

      result.should == 111
      hit.should be_false
    end
  end
end
