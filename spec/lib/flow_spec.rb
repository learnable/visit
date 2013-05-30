require 'spec_helper'

describe Visit::Flow do

  let(:relation) { Visit::Query::LabelledEvent.new([:capture1, :capture2]).scoped }
  let(:flows) { Visit::Flow.new_from_relation(relation) }

  before do
    start_with_visits [
      { url: "http://e.org/articles",     user_id: 11, token: 100 },
      { url: "http://e.org/articles/1",   user_id: 11, token: 100 },
      { url: "http://e.org/articles/2/3", user_id: 11, token: 100 },
    ]
  end

  context "#new_from_relation" do
    it "should return a non-empty array when events are present" do
      flows.should have(1).item
    end
  end

  context "#steps" do
    it "should return a useful string" do
      flows.first.steps.should == "articles_index -> article(1) -> subarticle(2/3)"
    end
  end

end
