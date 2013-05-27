require 'spec_helper'

describe Visit::Query::Trait do
  before do
    Visit::Event.destroy_all

    run_requests_through_factory [
      { url: "http://is-goog/1", },
      { url: "http://is-moz/1?utm_campaign=xxx", user_agent: "aa"   },
      { url: "http://is-moz/2?utm_campaign=yyy", user_agent: "bb"   }
    ]
  end

  subject { Visit::Query::Trait.new("utm_campaign") }

  its(:scoped) { should be_a_kind_of(ActiveRecord::Relation) }

  it "#scoped finds only the visit events that match the relation" do
    subject.scoped.all.map { |ve| ve.user_agent }.sort.should == ['aa', 'bb']
  end

  it "#scoped supports WHERE clauses that reference the trait" do
    subject.scoped.where("utm_campaign_vtv.v = 'yyy'").count.should == 1
  end
end
