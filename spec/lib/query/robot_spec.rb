require 'spec_helper'
require 'shared_gem_config'

describe Visit::Query::Robot do
  before do
    run_requests_through_factory [
      { url: "http://is-goog/1", user_agent: "googlebot" },
      { url: "http://is-moz/2",  user_agent: "mozilla"   }
    ]
  end

  subject { Visit::Query::Robot.new }

  its(:scoped) { should be_a_kind_of(ActiveRecord::Relation) }

  it "#scoped finds only events whose user_agent indicates a robot" do
    subject.scoped.count.should == 1
    subject.scoped.first.url.should =~ /is-goog/
  end
end
