require 'spec_helper'
require 'shared_gem_config'

describe Visit::Query::Trait do
  before do
    Visit::Event.destroy_all

    h1 = new_request_payload_hash url: "http://is-goog/1"
    h2 = new_request_payload_hash url: "http://is-moz/1?utm_campaign=xxx", user_agent: "aa"
    h3 = new_request_payload_hash url: "http://is-moz/2?utm_campaign=yyy", user_agent: "bb"

    Visit::Factory.run [ h1, h2, h3 ]
  end

  let(:query) { Visit::Query::Trait.new("utm_campaign") }

  context "#scoped" do
    it "returns an ActiveRecord::Relation" do
      query.scoped.class.should == ActiveRecord::Relation
    end

    it "finds only the visit events that match the relation" do
      query.scoped.all.map { |ve| ve.user_agent }.sort.should == ['aa', 'bb']
    end

    it "supports WHERE clauses that reference the trait" do
      query.scoped.where("utm_campaign_vtv.v = 'yyy'").count.should == 1
    end
  end
end
