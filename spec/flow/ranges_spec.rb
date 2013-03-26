require 'spec_helper'
require 'shared_gem_config'

describe Visit::Flow::Ranges do

  let(:user) { create :user }
  let!(:ve1) { create :visit_event, url: "http://e.org/articles", user: user, vid: 100 }
  let!(:ve2) { create :visit_event, url: "http://e.org/articles/1", user: user, vid: 100 }

  before do
    Visit::TraitFactory.new.run
  end

  it "gives the flows as ve.id ranges" do
    Visit::Flow::Ranges.for_user(user.id).first.should == (ve1.id..ve2.id)
  end
end
