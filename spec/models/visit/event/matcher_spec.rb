require 'spec_helper'
require 'shared_gem_config'

describe Visit::Event::Matcher do
  let(:klass) { Visit::Event::Matcher }
  let(:path) { "/articles" }

  describe ".first_match" do
    it "returns a matcher" do
      klass.first_match(:get, path).class.should == klass
    end
  end

  describe ".all" do
    it "returns the right number of matches" do
      klass.all.count.should == 2
      klass.all.each do |matcher|
        matcher.class.should == klass;
      end
    end
  end

  context "a matcher with http_method :get" do

    let(:matcher) do
      klass.first_match(:get, path)
    end

    describe "matches?" do

      it "matches http_method and path" do
        matcher.matches?("get", path).should be_true
      end

      it 'does not match garbage' do
        matcher.matches?("blah", "/art").should be_false
        matcher.matches?("post", "aldkcjka").should be_false
        matcher.matches?("get", "/article").should be_false
      end
    end

  end

  context "a matcher with http_method :any" do
    let(:matcher) do
      Visit::Event::Matcher.new :any, /^\/articles\/(\d)/, :articles, true
    end

    it "matches? :get" do
      matcher.matches?("get", "/articles/123").should be_true
    end
    it "matches? :post" do
      matcher.matches?("post", "/articles/123").should be_true
    end
  end
end
