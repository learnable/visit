require 'spec_helper'

describe Visit::Event::Traits do
  let(:traits) { Visit::Event::Traits.new(
    create(:visit_event, url: "http://thishost.org/articles")
  ) }

  # Use function as rspec warns against using 'let' variables in a
  # before :all block
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
    end
  end

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
