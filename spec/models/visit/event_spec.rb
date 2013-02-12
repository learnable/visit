require 'spec_helper'

describe Visit::Event do

  let(:ve)        { build :visit_event_course_utm }
  let(:utm)       { "aa__bb_cc_" }
  let(:course_id) { "11" }

  describe "#cols_should_be" do
    it "contains :course and :utm for course sales pages with utm params" do
      h = { :label => :course, :sublabel => course_id, :utm => utm }
      ve.cols_should_be.should == h
    end

    describe "sets coupon" do
      it "when there are coupon params" do
        h = (build :visit_event, :url => "/?mc=123").cols_should_be
        h.should have_key(:coupon)
        h[:coupon].should == "123"
      end

      it "when the coupon cookie is set" do
        h = (build :visit_event, :url => "/", :cookie_membership_coupon_token => "123").cols_should_be
        h.should have_key(:coupon)
        h[:coupon].should == "123"
      end
    end

    it "is nil for urls we don't care about" do
      (build :visit_event, :url => "/xyz").cols_should_be[:label].should be_nil
      (build :visit_event, :url => "/xyz").cols_should_be[:sublabel].should be_nil
    end

    it "is sensitive to request method when it is relevant, like during sign up" do
      (build :visit_event, { :http_method => "get",  :url => "/sign-in" }).cols_should_be[:label].should == :sign_in_prompt
      (build :visit_event, { :http_method => "post", :url => "/sign-in" }).cols_should_be[:label].should == :sign_in
    end
  end

  describe Visit::Event::Matcher do
    describe ".all" do
      it "returns a collection of Matcher instances" do
        matchers = Visit::Event::Matcher.all
        matchers.size.should >= 1
        matchers.each { |m| m.should be_a Visit::Event::Matcher }
      end
    end
  end
  
end
