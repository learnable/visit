require 'spec_helper'

describe Visit::Event::Matcher do
  let(:klass) { Visit::Event::Matcher }
  let(:path) { "/articles" }
  def labels
    [{
      :http_method  => :get,
      :re           => /^\/articles/,
      :label        => :articles_index,
      :has_sublabel => false
    }]
  end

  # Configure the gem
  before :all do
    Visit::Configurable.instance_exec(labels) do |_labels|
      @_labels = _labels
      def labels
        @_labels
      end
      def ignorable
        [
          /\/courses\/blah.js/,
          /\/system\/blah/,
        ]
      end
    end
  end

  describe ".first_match" do
    it "returns a matcher" do
      klass.first_match(:get, path).class.should == klass
    end
  end

  describe ".all" do
    it "returns the right number of matches" do
      klass.all.count.should == 1
      klass.all.each do |matcher|
        matcher.class.should == klass;
      end
    end
  end

  context "that should match /articles index" do
    let(:matcher) do
      klass.first_match(:get, path)
    end

    describe "matches?" do
      it "matches" do
        matcher.matches?("get", path).should be_true
      end
      it 'does not match garbage' do
        matcher.matches?("blah", "/art").should be_false
        matcher.matches?("post", "aldkcjka").should be_false
        matcher.matches?("get", "/article").should be_false
      end
    end

  end
end
