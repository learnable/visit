require 'spec_helper'

describe Visit::Event::Traits do

  let (:url) { "http://thishost.org/articles?gclid=4455&utm_source=fred" }

  subject { create(:visit_event, url: url).to_traits }

  context "for traits that are derived from url" do
    it "#to_h contains the key and value derived from match_first" do
      subject.to_h[:label].should == "articles_index"
    end

    it "#to_h contains keys and values deriving from match_all" do
      subject.to_h[:gclid].should == "4455"
      subject.to_h[:utm_source].should == "fred"
    end

    it "#to_h_fk[:url] has keys whose values are traits" do
      subject.to_h_fk[:url].keys.should_not be_empty
      subject.to_h_fk[:url].should == subject.to_h
    end

    it "#to_h_fk[:user_agent] is empty" do
      subject.to_h_fk[:user_agent].keys.should be_empty
    end

    context "when the url matches a trait that has no value" do
      let (:url) { "http://thishost.org/articles?trait_no_value" }

      it "the trait value is ''" do
        subject.to_h.has_key?(:trait_no_value).should be_true
        subject.to_h[:trait_no_value].should == ""
      end
    end
  end

  context "for traits that are derived from user_agent" do
    context "when user_agent isn't a robot" do
      it "#to_h.has_key?(:robot) should be false" do
        subject.to_h.has_key?(:robot).should be_false
      end
    end

    context "when user_agent is a robot" do
      subject { create(:visit_event, url: url , user_agent: "googlebot").to_traits }

      it "#to_h.has_key?(:robot) should be true" do
        subject.to_h.has_key?(:robot).should be_true
      end

      it "#to_h[:robot] contains the name of the robot" do
        subject.to_h[:robot].should == "google"
      end
    end

    it "#to_h_fk[:user_agent] has key :robot and an appropriate value" do
      subject.to_h_fk[:user_agent][:robot].should == subject.to_h[:robot]
    end
    it "#to_h_fk[:url] does not have key :robot" do
      subject.to_h_fk[:url].has_key?(:robot).should be_false
    end
  end
end
