require 'spec_helper'
require 'shared_gem_config'

describe Visit::Flow do
  let(:user) { create :user }
  let(:range) { Visit::Flow::Ranges.for_user(user.id).first }
  let(:flow) { Visit::Flow.new(range) }

  before do
    Visit::Event.destroy_all
    create :visit_event, url: "http://e.org/articles", user: user, vid: 100
    create :visit_event, url: "http://e.org/articles/1", user: user, vid: 100
    create :visit_event, url: "http://e.org/articles/2/3", user: user, vid: 100
    # Run factory to assign labels to visit events in order for Flow to
    # register the events
    Visit::TraitFactory.new.run
  end

  context "Flow::Ranges.for_user" do
    it "should return a non-empty array when events are present" do
      range.should_not be_nil
    end
  end

  context "Flow.steps" do
    it "should return a useful string" do
      flow.steps.should == "articles_index -> article(1) -> subarticle(2/3)"
    end
  end
end
