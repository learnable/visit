require 'spec_helper'
require 'shared_gem_config'

describe Visit::UserAgentRobotQuery do
  let(:user) { create :user }

  before do
    create :visit_event, url: "http://e.org/articles", user: user, vid: 100, user_agent: "hello world"
    create :visit_event, url: "http://e.org/articles/1", user: user, vid: 101, user_agent: "googlebot"
    Visit::TraitFactory.new.run
  end

  it "finds events whose user_agent string screams 'robot'" do
    Visit::UserAgentRobotQuery.new.scoped.first.vid.should == 101
  end

  it "ignores events whose user_agent string doesn't smell of 'robot'" do
    Visit::UserAgentRobotQuery.new.scoped.count.should == 1
  end
end
