require 'spec_helper'
require 'shared_gem_config'

describe Visit::Event::MatcherCollection do

  describe "#match_first_to_h" do
    let(:matcher_collection) { Visit::Event::MatcherCollection.new Visit::Configurable.labels_match_first }

    it "returns hash with a :label when there's a match to a label" do
      h = matcher_collection.match_first_to_h(:get, "/articles")

      h.class.should == Hash
      h.has_key?(:label).should be_true
      h[:label].should == :articles_index
    end

    it "returns hash with a :label and :sublabel when appropriate" do
      h = matcher_collection.match_first_to_h(:get, "/articles/123")

      h.class.should == Hash
      h.has_key?(:label).should be_true
      h.has_key?(:sublabel).should be_true
      h[:label].should == :article
      h[:sublabel].should == "123"
    end

    it "returns an empty hash when there's no match'" do
      h = matcher_collection.match_first_to_h(:get, "/blah")

      h.class.should == Hash
      h.should be_empty
    end
  end
  
  describe "#match_all_to_a" do
    let(:matcher_collection) { Visit::Event::MatcherCollection.new Visit::Configurable.labels_match_all }

    it "returns an array of hashes when there are matches " do
      a = matcher_collection.match_all_to_a(:get, "/blah?gclid=xx&utm_source=yy&utm_campaign=zz")

      a.class.should == Array
      h = a.inject(&:merge)

      h.length.should == 3

      h[:gclid].should == "xx"
      h[:utm_source].should == "yy"
      h[:utm_campaign].should == "zz"
    end

    it "returns an array with an empty hash when there's no match'" do
      a = matcher_collection.match_all_to_a(:get, "/blah")

      a.length.should == 1
      h = a.inject(&:merge)

      h.should be_empty
    end
  end
end
