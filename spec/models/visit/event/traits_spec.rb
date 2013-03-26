require 'spec_helper'

describe Visit::Event::Traits do
  let(:ve) { create(:visit_event, url: "http://thishost.org/articles") }
  let(:traits) { Visit::Event::Traits.new(ve) }

  include_context "gem_config"

  ##### Finally, the tests:

  describe "#to_h" do
    it "should return a hash" do
      traits.to_h.kind_of?(Hash).should be_true
    end
    it "returns the visit_event's label" do
      traits.to_h[:label].should == :articles_index
    end
  end
end
