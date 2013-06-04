require 'spec_helper'

describe Visit::Event::Traits do
  let(:ve) { create(:visit_event, url: "http://thishost.org/articles?gclid=4455") }
  let(:traits) { ve.to_traits }

  context "for traits that are derived from url" do
    it "has_key?(:label) works as expected" do
      traits[:label].should == :articles_index
    end
    it "has_key?(:glcid) works as expected" do
      traits[:gclid].should == "4455"
    end
  end

  context "for traits that are derived from user_agent" do
    context "when user_agent isn't a robot" do
      it "#has_key?(:robot) should be false" do
        traits.has_key?(:robot).should be_false
      end
    end

    context "when user_agent is a robot" do

      let(:ve) { create(:visit_event, url: "http://thishost.org/articles?gclid=4455", user_agent: "googlebot") }

      it "#has_key?(:robot) should be true" do
        traits.has_key?(:robot).should be_true
      end

      it "#[:robot] contains the .to_s of the regexp that matched the user agent" do
        traits[:robot].should == :google
      end
    end
  end
end
