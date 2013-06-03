require 'spec_helper'

describe Visit::Flow do

  let(:relation) { Visit::Query::LabelledEvent.new([:capture1, :capture2]).scoped }
  let(:flows) { Visit::Flow.new_from_relation(relation) }

  let(:relation_reversed) { relation.order("id DESC") }
  let(:flows_reversed) { Visit::Flow.new_from_relation(relation_reversed) }

  before do
    start_with_visits [
      { url: "http://e.org/articles",     user_id: 11, token: 100, created_at: Time.now - 3.minutes },
      { url: "http://e.org/articles/1",   user_id: 11, token: 100, created_at: Time.now - 2.minutes },
      { url: "http://e.org/articles/2/3", user_id: 11, token: 100, created_at: Time.now - 2.minutes },
      { url: "http://e.org/articles",                  token: 200 },
      { url: "http://e.org/articles/1",                token: 200 },
    ]
  end

  context "#new_from_relation" do
    it "should return a non-empty array when events are present" do
      flows.should have(2).items
    end
    it "respects the ORDER of the relation" do
      flows_reversed.first.events.should have(2).items
    end
  end

  context "#steps" do
    it "returns a string that hints at the flow" do
      flows.first.steps.should == "articles_index -> article(1) -> subarticle(2/3)"
    end
    it "isn't influenced by the ORDER of the relation" do
      flows_reversed.last.steps.should == "articles_index -> article(1) -> subarticle(2/3)"
    end
  end

  context "#user_id" do
    it "should return the first non-null user_id" do
      flows.second.user_id.should be_nil
    end
    it "should return nil when the flow doens't have any events with user_id set" do
      flows.first.user_id.should == 11
    end
  end

end
