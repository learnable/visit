require 'spec_helper'
require 'shared_gem_config'

describe Visit::Event::Traits do
  let(:ve) { create(:visit_event, url: "http://thishost.org/articles?gclid=4455") }
  let(:traits) { Visit::Event::Traits.new(ve) }

  ##### Finally, the tests:

  describe "#to_h" do
    it "returns a hash" do
      traits.to_h.kind_of?(Hash).should be_true
    end
    it "has_key? :label" do
      traits.to_h[:label].should == :articles_index
    end
    it "has_key? :glcid " do
      traits.to_h[:gclid].should == "4455"
    end
  end
end
