require 'spec_helper'

describe Visit::Query::UserAgentRobot do
  before do
    ve1 = create(:visit_event, url: "http://is-goog/1", user_agent: "googlebot")
    ve2 = create(:visit_event, url: "http://is-moz/2", user_agent: "mozilla")

    Visit::TraitFactory.new.create_traits_for_visit_events [ ve1, ve2 ]
  end

  let(:query) { Visit::Query::UserAgentRobot.new }

  context "#scoped" do
    it "returns an ActiveRecord::Relation" do
      query.scoped.class.should == ActiveRecord::Relation
    end
    it "only finds events whose user_agent indicates a robot" do
      query.scoped.count.should == 1
      query.scoped.first.url.should =~ /is-goog/
    end
  end
end
