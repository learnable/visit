require 'spec_helper'
require 'shared_gem_config'

describe Visit::Flow::Ranges do

  let(:user) { create :user }
  let!(:h1) { new_request_payload_hash url: "http://e.org/articles", user_id: user.id }
  let!(:h2) { new_request_payload_hash url: "http://e.org/articles/1", user_id: user.id }

  before do
    Visit::Factory.run [ h1, h2 ]
  end

  it "gives the flows as ve.id ranges" do
    first = Visit::Flow::Ranges.for_user(user.id).first

    first.class == Range
    Visit::Event.find(first.begin).url.should == h1[:url]
    Visit::Event.find(first.end).url.should == h2[:url]
  end
end
