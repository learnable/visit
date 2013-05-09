require 'spec_helper'

describe Visit::Query::Trait do
  before do
    ve1 = create(:visit_event, url: "http://is-goog/1" )
    ve2 = create(:visit_event, url: "http://is-moz/1?utm_campaign=xxx", user_agent: 'aa')
    ve3 = create(:visit_event, url: "http://is-moz/2?utm_campaign=yyy", user_agent: 'bb')

    Visit::TraitFactory.new.create_traits_for_visit_events [ ve1, ve2, ve3 ]
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
