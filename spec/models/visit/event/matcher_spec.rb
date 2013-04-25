require 'spec_helper'
require 'shared_gem_config'

describe Visit::Event::Matcher do
  context "a matcher with http_method :get" do
    let(:matcher) { Visit::Event::Matcher.new :get, %r{^/articles(\?.*|)$}, :articles_index }
    let(:path) { "/articles" }

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
    let(:matcher) { Visit::Event::Matcher.new :any, /^\/articles\/(\d+)/, :article }
    let(:path) { "/articles/123" }

    it "matches? :get" do
      matcher.matches?("get", path).should be_true
    end
    it "matches? :post" do
      matcher.matches?("post", path).should be_true
    end
  end

  context "matchdata_to_label_h" do
    context "after matches?" do
      context "to a regexp with no captures" do
        let(:matcher) { Visit::Event::Matcher.new :get, %r{^/articles(\?.*|)$}, :articles_index }
        let(:path) { "/articles" }

        before { matcher.matches?("get", path).should be_true }

        it "returns a hash with :label" do
          h = matcher.matchdata_to_label_h

          h.has_key?(:label).should be_true
          h[:label].should == :articles_index
        end
      end

      context "to a regexp with one capture" do
        let(:matcher) { Visit::Event::Matcher.new :any, /^\/articles\/(\d+)/, :article }
        let(:path) { "/articles/123" }

        before { matcher.matches?("get", path).should be_true }

        it "returns a hash with :label and :capture1" do
          h = matcher.matchdata_to_label_h

          h.has_key?(:label).should be_true
          h.has_key?(:capture1).should be_true
          h[:label].should == :article
          h[:capture1].should == "123"
        end
      end
      
      context "to a regexp with two captures" do
        let(:matcher) { Visit::Event::Matcher.new :any, %r{^/articles/(\d+)/(\d+)}, :article }
        let(:path) { "/articles/123/456" }

        before { matcher.matches?("get", path).should be_true }

        it "returns a hash with :label, :capture1 and :capture2" do
          h = matcher.matchdata_to_label_h

          h.has_key?(:label).should be_true
          h.has_key?(:capture1).should be_true
          h.has_key?(:capture2).should be_true
          h[:label].should == :article
          h[:capture1].should == "123"
          h[:capture2].should == "456"
        end
      end
    end
  end

  context "matchdata_to_value_h" do
    context "after matches?" do
      let(:matcher) { Visit::Event::Matcher.new :any, /^\/articles\/(\d+)/, :article }
      let(:path) { "/articles/123" }

      before { matcher.matches?("get", path) }

      it "returns a hash whose key is label and value is capture1" do
        h = matcher.matchdata_to_value_h

        h.has_key?(:article).should be_true
        h[:article].should == "123"
      end
    end
  end
end
