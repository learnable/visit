require 'spec_helper'
require 'shared_gem_config'

describe Visit::Event::Traits do
  let(:ve) { create(:visit_event, url: "http://thishost.org/articles?gclid=4455") }
  let(:traits) { Visit::Event::Traits.new(ve) }

  describe "#to_h" do
    it "returns a hash" do
      traits.to_h.kind_of?(Hash).should be_true
    end
  end

  context "for traits that are derived from url" do
    describe "#to_h" do
      it "has_key?(:label) works as expected" do
        traits.to_h[:label].should == :articles_index
      end
      it "has_key?(:glcid) works as expected" do
        traits.to_h[:gclid].should == "4455"
      end
    end
  end

  context "for traits that are derived from user_agent" do
    context "when user_agent isn't a robot" do
      it "#to_h.has_key?(:robot) should be false" do
        traits.to_h.has_key?(:robot).should be_false
      end
    end

    context "when user_agent is a robot" do
      let(:ve) { create(:visit_event, url: "http://thishost.org/articles?gclid=4455", user_agent: "googlebot") }
      it "#to_h.has_key?(:robot) should be true" do
        traits.to_h.has_key?(:robot).should be_true
      end
      it "#to_h[:robot] contains the .to_s of the regexp that matched the user agent" do
        traits.to_h[:robot].should =~ /googlebot/i
      end
    end
  end
end
