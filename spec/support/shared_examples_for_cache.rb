shared_examples "Cache" do

  before { cache.clear }
  after { cache.clear }

  let(:k1) { Visit::Cache::Key.new("", 111) }
  let(:k2) { Visit::Cache::Key.new("", 222) }

  context "with some keys in the cache" do
    before do
      cache.fetch(k1) { 111 }
      cache.fetch(k2) { 222 }
    end

    context "#clear" do
      it "should delete all keys" do
        cache.has_key?(k1).should be_true
        cache.has_key?(k2).should be_true

        cache.clear

        cache.has_key?(k1).should be_false
        cache.has_key?(k2).should be_false
      end
    end

    context "#delete" do
      it "should delete a key" do
        cache.has_key?(k1).should be_true
        cache.delete(k1)
        cache.has_key?(k1).should be_false

        cache.has_key?(k2).should be_true
        cache.delete(k2)
        cache.has_key?(k2).should be_false
      end
    end
  end

  context "#fetch" do
    it "should evaluate to it's block" do
      cache.fetch(k1) { 111 }.should == 111
    end

    context "should hit cache" do
      it "on the first fetch of a key but not the second" do
        hit = ""
        cache.fetch(k1) { 111; hit += "a" }
        cache.fetch(k1) { 111; hit += "b" }
        hit.should == "a"
      end

      it "on the first fetch of a key after #clear" do
        hit = ""
        cache.fetch(k1) { 111; hit += "a" }
        cache.fetch(k1) { 111; hit += "b" }
        cache.clear
        cache.fetch(k1) { 111; hit += "c" }
        hit.should == "ac"
      end
    end

    it "takes options" do
      cache.fetch(k1, expires_in: 1.second) {}
    end
  end
  
  context "#has_key?" do
    it "should return false when key not present" do
      cache.has_key?(k1).should be_false
    end
    it "should return true when key present" do
      cache.fetch(k1) { 111 }
      cache.has_key?(k1).should be_true
    end
    it "should have no side effects" do
      cache.fetch(k1) { 111 }

      hit = false
      result = cache.fetch(k1) { 111; hit = true }

      result.should == 111
      hit.should be_false
    end
  end
end
