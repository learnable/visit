require 'spec_helper'
require 'shared_gem_config'

describe Visit::Flow do
  let(:user) { create :user }
  let(:range) { Visit::Flow::Ranges.for_user(user.id).first }
  let(:flow) { Visit::Flow.new(range) }

  before do
    create :visit_event, url: "http://e.org/articles", user: user, vid: 100
    create :visit_event, url: "http://e.org/articles/1", user: user, vid: 100
    # Run factory to assign labels to visit events in order for Flow to
    # register the events
    Visit::TraitFactory.new.run
  end

  it "shows flow steps" do
    flow.steps.should == "articles_index -> article(1)"
  end
end
