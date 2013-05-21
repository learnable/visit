require 'spec_helper'
require 'shared_gem_config'

describe Visit::Query::Robot do
  before do
    h1 = new_request_payload_hash url: "http://is-goog/1", user_agent: "googlebot"
    h2 = new_request_payload_hash url: "http://is-moz/2", user_agent: "mozilla"

    Visit::Factory.run [ h1, h2 ]
  end

  let(:query) { Visit::Query::Robot.new }

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
