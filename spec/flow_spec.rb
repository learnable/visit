require 'spec_helper'
require 'shared_gem_config'

describe Visit::Flow do
  let(:user) { create :user }
  let(:range) { Visit::Flow::Ranges.for_user(user.id).first }
  let(:flow) { Visit::Flow.new(range) }

  before do
    Visit::Event.destroy_all
    h1 = new_request_payload_hash url: "http://e.org/articles", user_id: user.id, vid: 100
    h2 = new_request_payload_hash url: "http://e.org/articles/1", user_id: user.id, vid: 100
    h3 = new_request_payload_hash url: "http://e.org/articles/2/3", user_id: user.id, vid: 100
    Visit::Factory.run [ h1, h2, h3 ]
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
