require 'spec_helper'
require 'shared_gem_config'

describe Visit::Event::Matcher do
  context "a matcher with http_method :get" do
    let(:matcher) { Visit::Event::Matcher.new :get, %r{^/articles(\?.*|)$}, :articles_index, false }
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
    let(:matcher) { Visit::Event::Matcher.new :any, /^\/articles\/(\d+)/, :article, true }
    let(:path) { "/articles/123" }

    it "matches? :get" do
      matcher.matches?("get", path).should be_true
    end
    it "matches? :post" do
      matcher.matches?("post", path).should be_true
    end
  end

  context "result_to_label_h" do
    context "after matches? to a :label" do
      let(:matcher) { Visit::Event::Matcher.new :get, %r{^/articles(\?.*|)$}, :articles_index, false }
      let(:path) { "/articles" }

      before do
        matcher.matches?("get", path).should be_true
      end

      it "returns a hash with :label" do
        h = matcher.result_to_label_h

        h.has_key?(:label).should be_true
        h[:label].should == :articles_index
      end
    end

    context "after matches? to a :label and :sublabel" do
      let(:matcher) { Visit::Event::Matcher.new :any, /^\/articles\/(\d+)/, :article, true }
      let(:path) { "/articles/123" }

      before do
        matcher.matches?("get", path).should be_true
      end

      it "returns a hash with :label and :sublabel" do
        h = matcher.result_to_label_h

        h.has_key?(:label).should be_true
        h.has_key?(:sublabel).should be_true
        h[:label].should == :article
        h[:sublabel].should == "123"
      end
    end
  end

  context "result_to_value_h" do
    context "after matches?" do
      let(:matcher) { Visit::Event::Matcher.new :any, /^\/articles\/(\d+)/, :article, true }
      let(:path) { "/articles/123" }

      before { matcher.matches?("get", path) }

      it "returns a hash whose key is label and value is sublabel" do
        h = matcher.result_to_value_h

        h.has_key?(:article).should be_true
        h[:article].should == "123"
      end
    end
  end
end
